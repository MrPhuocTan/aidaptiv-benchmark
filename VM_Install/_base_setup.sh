#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Base Setup (Shared Library)
# ==============================================================================
# This script is sourced by each model-specific installer.
# It installs all benchmark tools, the monitoring agent, and configures ports.
# Do NOT run this file directly — use the model-specific install_*.sh scripts.
# ==============================================================================

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

print_status()  { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }
print_header()  { echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════════${NC}"; echo -e "${BOLD}${CYAN}  $1${NC}"; echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════${NC}\n"; }

# ── Port Mapping ──────────────────────────────────────────────────────────────
OLLAMA_PORT=11434
AGENT_PORT=9100
BENCHMARK_PORT=8443
AGENT_DIR="/opt/aidaptiv-agent"

# ==============================================================================
# 1. System Update & Dependencies
# ==============================================================================
install_system_deps() {
    print_header "1. System Update & Dependencies"
    sudo apt-get update -qq
    sudo apt-get upgrade -y -qq
    sudo apt-get install -y -qq \
        curl wget git build-essential \
        python3 python3-pip python3-venv \
        jq htop nvtop lsof net-tools \
        lshw pciutils lm-sensors smartmontools dmidecode sysstat
    print_success "System dependencies installed"

    # Initialize sensors for temperature/fan monitoring
    sudo sensors-detect --auto 2>/dev/null || true
}

# ==============================================================================
# 2. NVIDIA Driver & CUDA Validation
# ==============================================================================
validate_gpu() {
    print_header "2. GPU Validation"
    if ! command -v nvidia-smi &>/dev/null; then
        print_warning "NVIDIA driver not found! Proceeding with CPU-only mode."
        print_warning "Inference will be significantly slower."
        return 0
    fi

    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
    DRIVER_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)

    print_success "GPU Detected: ${GPU_NAME}"
    print_success "VRAM: ${GPU_VRAM} MB"
    print_success "Driver: ${DRIVER_VER}"

    if command -v nvcc &>/dev/null; then
        CUDA_VER=$(nvcc --version | grep "release" | awk '{print $5}' | tr -d ',')
        print_success "CUDA: ${CUDA_VER}"
    else
        print_warning "CUDA toolkit not found (optional for Ollama-based benchmarks)"
    fi
}

# ==============================================================================
# 3. Install Ollama
# ==============================================================================
install_ollama() {
    print_header "3. Installing Ollama"
    if command -v ollama &>/dev/null; then
        print_warning "Ollama already installed: $(ollama --version 2>/dev/null || echo 'installed')"
    else
        curl -fsSL https://ollama.com/install.sh | sh
        print_success "Ollama installed"
    fi

    # Configure Ollama for external access
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
Environment="OLLAMA_NUM_PARALLEL=4"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable ollama 2>/dev/null || true
    sudo systemctl restart ollama 2>/dev/null || true

    # Wait for Ollama to be ready
    sleep 3
    for i in {1..10}; do
        if curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null 2>&1; then
            print_success "Ollama is running on port ${OLLAMA_PORT}"
            return 0
        fi
        sleep 2
    done
    print_warning "Ollama may need manual start: ollama serve"
}

# ==============================================================================
# 4. Install Benchmark Tools
# ==============================================================================
install_benchmark_tools() {
    print_header "4. Installing Benchmark Tools"

    # ── oha (HTTP load tester — Rust) ─────────────────────────────────────
    print_status "Installing oha..."
    if command -v oha &>/dev/null; then
        print_warning "oha already installed"
    else
        OHA_VERSION="1.4.6"
        wget -q "https://github.com/hatoo/oha/releases/download/v${OHA_VERSION}/oha-linux-amd64" -O /tmp/oha
        chmod +x /tmp/oha
        sudo mv /tmp/oha /usr/local/bin/oha
        print_success "oha installed"
    fi



    # ── Python benchmark tools ────────────────────────────────────────────
    print_status "Installing Python benchmark tools..."
    pip3 install --quiet --upgrade --break-system-packages \
        litellm \
        locust \
        llmperf \
        httpx \
        openai \
        vllm 2>/dev/null || \
    pip3 install --quiet --user --upgrade --break-system-packages \
        litellm \
        locust \
        llmperf \
        httpx \
        openai \
        vllm
    print_success "Python benchmark tools installed (litellm, locust, llmperf, vllm)"
}

# ==============================================================================
# 5. Install Benchmark Agent (FastAPI on port 9100)
# ==============================================================================
install_agent() {
    print_header "5. Installing Benchmark Agent"

    sudo mkdir -p ${AGENT_DIR}

    # Create agent script
    sudo tee ${AGENT_DIR}/agent.py > /dev/null <<'AGENT_EOF'
#!/usr/bin/env python3
"""aiDaptiv Benchmark Agent — Collects GPU/CPU/Disk/Network metrics"""

import subprocess, json, os, time
from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="aiDaptiv Benchmark Agent", version="2.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True,
                   allow_methods=["*"], allow_headers=["*"])

def run_cmd(cmd, timeout=5):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return r.stdout.strip() if r.returncode == 0 else None
    except: return None

@app.get("/health")
async def health():
    return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}

@app.get("/metrics/gpu")
async def gpu_metrics():
    try:
        result = subprocess.run(
            ["nvidia-smi", "--query-gpu=index,name,memory.total,memory.used,memory.free,utilization.gpu,utilization.memory,temperature.gpu,power.draw",
             "--format=csv,noheader,nounits"], capture_output=True, text=True, timeout=5)
        if result.returncode != 0: return {"error": "nvidia-smi failed", "gpus": []}
        gpus = []
        for line in result.stdout.strip().split("\n"):
            if line:
                p = [x.strip() for x in line.split(",")]
                if len(p) >= 9:
                    gpus.append({"index": int(p[0]), "name": p[1],
                        "memory_total_mb": float(p[2]), "memory_used_mb": float(p[3]),
                        "memory_free_mb": float(p[4]),
                        "gpu_util_pct": float(p[5]) if p[5] not in ["[N/A]","N/A"] else 0,
                        "memory_util_pct": float(p[6]) if p[6] not in ["[N/A]","N/A"] else 0,
                        "temperature_c": float(p[7]) if p[7] not in ["[N/A]","N/A"] else 0,
                        "power_w": float(p[8]) if p[8] not in ["[N/A]","N/A"] else 0})
        return {"gpus": gpus, "timestamp": datetime.utcnow().isoformat()}
    except Exception as e: return {"error": str(e), "gpus": []}

@app.get("/metrics/system")
async def system_metrics():
    try:
        cpu = run_cmd("top -bn1 | grep 'Cpu(s)' | awk '{print $2}'")
        mem = run_cmd("free -m | awk 'NR==2{printf \"%s %s %s\", $2, $3, $4}'")
        mp = mem.split() if mem else ["0","0","0"]
        load = run_cmd("cat /proc/loadavg | awk '{print $1, $2, $3}'")
        lp = load.split() if load else ["0","0","0"]
        disk = run_cmd("df -h / | awk 'NR==2{print $2, $3, $5}'")
        dp = disk.split() if disk else ["0","0","0%"]
        # Disk I/O
        dr, dw = None, None
        try:
            def _ds():
                tr, tw = 0, 0
                with open("/proc/diskstats") as f:
                    for l in f:
                        pp = l.split()
                        if len(pp)>=14:
                            dn = pp[2]
                            if dn.startswith(("sd","nvme","vd")) and not any(c.isdigit() for c in dn.replace("nvme","").replace("n1","")):
                                tr += int(pp[5]); tw += int(pp[9])
                return tr, tw
            r1,w1 = _ds(); time.sleep(0.5); r2,w2 = _ds()
            dr = round((r2-r1)*512/(0.5*1024*1024),2); dw = round((w2-w1)*512/(0.5*1024*1024),2)
        except: pass
        # Network I/O
        nr, nt = None, None
        try:
            def _nd():
                rx, tx = 0, 0
                with open("/proc/net/dev") as f:
                    for l in f:
                        l = l.strip()
                        if ":" in l and not l.startswith("lo"):
                            pp = l.split(); iface = pp[0].rstrip(":")
                            if iface not in ("lo","docker0"):
                                rx += int(pp[1]); tx += int(pp[9])
                return rx, tx
            rx1,tx1 = _nd(); time.sleep(0.5); rx2,tx2 = _nd()
            nr = round((rx2-rx1)/(0.5*1024*1024),2); nt = round((tx2-tx1)/(0.5*1024*1024),2)
        except: pass
        return {"cpu_usage_pct": float(cpu) if cpu else 0,
            "memory_total_mb": int(mp[0]), "memory_used_mb": int(mp[1]), "memory_free_mb": int(mp[2]),
            "load_avg_1m": float(lp[0]), "load_avg_5m": float(lp[1]), "load_avg_15m": float(lp[2]),
            "disk_total": dp[0], "disk_used": dp[1], "disk_used_pct": dp[2],
            "disk_read_mbps": dr, "disk_write_mbps": dw,
            "network_rx_mbps": nr, "network_tx_mbps": nt,
            "timestamp": datetime.utcnow().isoformat()}
    except Exception as e: return {"error": str(e)}

@app.get("/ollama/status")
async def ollama_status():
    try:
        import httpx
        async with httpx.AsyncClient(timeout=5) as client:
            resp = await client.get("http://localhost:11434/api/tags")
            if resp.status_code == 200:
                data = resp.json()
                return {"online": True, "models": [m["name"] for m in data.get("models", [])]}
        return {"online": False, "models": []}
    except: return {"online": False, "models": []}

@app.get("/info")
async def server_info():
    return {
        "hostname": run_cmd("hostname") or "unknown",
        "kernel": run_cmd("uname -r") or "unknown",
        "uptime": run_cmd("uptime -p") or "unknown",
        "cpu_model": run_cmd("lscpu | grep 'Model name' | cut -f2 -d':' | awk '{$1=$1}1'") or "Unknown",
        "cpu_cores": run_cmd("nproc") or "0",
        "ram_gb": run_cmd("free -g | awk 'NR==2{print $2}'") or "0",
        "ssd_total": run_cmd("df -h / | awk 'NR==2{print $2}'") or "0",
        "gpu_name": (run_cmd("nvidia-smi --query-gpu=name --format=csv,noheader") or "No GPU").split("\\n")[0],
        "gpu_driver": (run_cmd("nvidia-smi --query-gpu=driver_version --format=csv,noheader") or "N/A").split("\\n")[0],
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9100)
AGENT_EOF

    # Requirements
    sudo tee ${AGENT_DIR}/requirements.txt > /dev/null <<'REQ_EOF'
fastapi==0.109.0
uvicorn==0.27.0
httpx==0.26.0
REQ_EOF

    # Virtual environment
    cd ${AGENT_DIR}
    sudo python3 -m venv venv
    sudo ${AGENT_DIR}/venv/bin/pip install -q -r requirements.txt
    print_success "Agent dependencies installed"

    # systemd service
    sudo tee /etc/systemd/system/aidaptiv-agent.service > /dev/null <<'SVC_EOF'
[Unit]
Description=aiDaptiv Benchmark Agent
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/aidaptiv-agent
ExecStart=/opt/aidaptiv-agent/venv/bin/python /opt/aidaptiv-agent/agent.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVC_EOF

    sudo systemctl daemon-reload
    sudo systemctl enable aidaptiv-agent
    sudo systemctl restart aidaptiv-agent
    print_success "Agent service started on port ${AGENT_PORT}"
}

# ==============================================================================
# 6. Firewall & Port Opening (ufw + iptables + GCP)
# ==============================================================================
configure_firewall() {
    print_header "6. Opening Ports (${OLLAMA_PORT}, ${AGENT_PORT})"

    # ── 6a. UFW ────────────────────────────────────────────────────────────
    if command -v ufw &>/dev/null; then
        print_status "Configuring ufw..."
        sudo ufw allow 22/tcp comment 'SSH'                          2>/dev/null || true
        sudo ufw allow ${OLLAMA_PORT}/tcp comment 'Ollama API'       2>/dev/null || true
        sudo ufw allow ${AGENT_PORT}/tcp  comment 'Benchmark Agent'  2>/dev/null || true
        sudo ufw --force enable 2>/dev/null || true
        print_success "ufw: ports ${OLLAMA_PORT}, ${AGENT_PORT} opened"
    else
        print_warning "ufw not found — skipping"
    fi

    # ── 6b. iptables (fallback) ────────────────────────────────────────────
    print_status "Configuring iptables..."
    for PORT in ${OLLAMA_PORT} ${AGENT_PORT}; do
        sudo iptables -C INPUT -p tcp --dport ${PORT} -j ACCEPT 2>/dev/null || \
            sudo iptables -A INPUT -p tcp --dport ${PORT} -j ACCEPT 2>/dev/null || true
    done
    # Persist iptables rules
    if command -v netfilter-persistent &>/dev/null; then
        sudo netfilter-persistent save 2>/dev/null || true
    elif command -v iptables-save &>/dev/null; then
        sudo iptables-save | sudo tee /etc/iptables.rules > /dev/null 2>/dev/null || true
    fi
    print_success "iptables: ports ${OLLAMA_PORT}, ${AGENT_PORT} opened"

    # ── 6c. GCP Firewall (if running on Google Cloud) ─────────────────────
    if command -v gcloud &>/dev/null; then
        print_status "Detected GCP environment — creating firewall rules..."
        local GCP_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
        if [ -n "${GCP_PROJECT}" ]; then
            gcloud compute firewall-rules create allow-ollama-${OLLAMA_PORT} \
                --project="${GCP_PROJECT}" \
                --direction=INGRESS --priority=1000 --network=default \
                --action=ALLOW --rules=tcp:${OLLAMA_PORT} \
                --source-ranges=0.0.0.0/0 \
                --description="Allow Ollama API" 2>/dev/null || \
                print_warning "GCP firewall rule for ${OLLAMA_PORT} already exists or failed"

            gcloud compute firewall-rules create allow-agent-${AGENT_PORT} \
                --project="${GCP_PROJECT}" \
                --direction=INGRESS --priority=1000 --network=default \
                --action=ALLOW --rules=tcp:${AGENT_PORT} \
                --source-ranges=0.0.0.0/0 \
                --description="Allow Benchmark Agent" 2>/dev/null || \
                print_warning "GCP firewall rule for ${AGENT_PORT} already exists or failed"

            print_success "GCP firewall: rules created for project ${GCP_PROJECT}"
        else
            print_warning "GCP project not set — skip GCP firewall"
        fi
    fi

    # ── 6d. Verify ports are actually listening ───────────────────────────
    print_status "Verifying port accessibility..."
    sleep 2
    for PORT in ${OLLAMA_PORT} ${AGENT_PORT}; do
        if ss -tlnp | grep -q ":${PORT} "; then
            print_success "Port ${PORT}: LISTENING ✓"
        else
            print_warning "Port ${PORT}: NOT LISTENING — service may not be running yet"
        fi
    done
}

# ==============================================================================
# 7. Pull Model via Ollama
# ==============================================================================
pull_ollama_model() {
    local MODEL_TAG="$1"
    local MODEL_DISPLAY="$2"

    print_header "7. Pulling Model: ${MODEL_DISPLAY}"
    print_status "Downloading ${MODEL_TAG} via Ollama..."
    print_status "(This may take a while depending on model size and connection speed)"

    if ollama pull "${MODEL_TAG}"; then
        print_success "Model ${MODEL_TAG} pulled successfully"
    else
        print_error "Failed to pull ${MODEL_TAG}"
        print_status "Try manually: ollama pull ${MODEL_TAG}"
        return 1
    fi

    # Verify model is available
    if ollama list | grep -q "${MODEL_TAG}"; then
        local MODEL_SIZE=$(ollama list | grep "${MODEL_TAG}" | awk '{print $2}')
        print_success "Model verified: ${MODEL_TAG} (${MODEL_SIZE})"
    fi
}

# ==============================================================================
# 8. Create Deterministic Model (for reproducible benchmarks)
# ==============================================================================
create_deterministic_model() {
    local BASE_MODEL="$1"
    local DET_MODEL="$2"

    print_header "8. Creating Deterministic Model"
    print_status "Creating ${DET_MODEL} from ${BASE_MODEL} with fixed parameters..."

    cat > /tmp/Modelfile.deterministic <<EOF
FROM ${BASE_MODEL}
PARAMETER temperature 0
PARAMETER top_p 1.0
PARAMETER top_k 1
PARAMETER seed 42
PARAMETER num_predict 512
EOF

    if ollama create "${DET_MODEL}" -f /tmp/Modelfile.deterministic; then
        print_success "Deterministic model created: ${DET_MODEL}"
    else
        print_warning "Could not create deterministic model. Using base model."
    fi
    rm -f /tmp/Modelfile.deterministic
}

# ==============================================================================
# 9. Environment Variable Mapping (for benchmark connectivity)
# ==============================================================================
setup_env_mapping() {
    local MODEL_TAG="$1"

    print_header "9. Environment Variable Mapping"

    SERVER_IP=$(hostname -I | awk '{print $1}')
    EXTERNAL_IP=$(curl -s ifconfig.me 2>/dev/null || echo "${SERVER_IP}")

    # Create /etc/profile.d script so all users inherit benchmark vars
    sudo tee /etc/profile.d/aidaptiv-benchmark.sh > /dev/null <<ENVEOF
# aiDaptiv Benchmark — Environment Variables
export AIDAPTIV_OLLAMA_URL="http://${SERVER_IP}:${OLLAMA_PORT}"
export AIDAPTIV_AGENT_URL="http://${SERVER_IP}:${AGENT_PORT}"
export AIDAPTIV_OLLAMA_PORT=${OLLAMA_PORT}
export AIDAPTIV_AGENT_PORT=${AGENT_PORT}
export AIDAPTIV_MODEL="${MODEL_TAG}"
export AIDAPTIV_SERVER_IP="${SERVER_IP}"
export AIDAPTIV_EXTERNAL_IP="${EXTERNAL_IP}"
export OLLAMA_HOST=0.0.0.0:${OLLAMA_PORT}
export OLLAMA_ORIGINS="*"
ENVEOF
    sudo chmod +x /etc/profile.d/aidaptiv-benchmark.sh
    source /etc/profile.d/aidaptiv-benchmark.sh

    # Also write a connection info file for easy copy-paste
    sudo tee /opt/aidaptiv-agent/connection_info.json > /dev/null <<CONNEOF
{
  "server_ip": "${SERVER_IP}",
  "external_ip": "${EXTERNAL_IP}",
  "ollama_url": "http://${SERVER_IP}:${OLLAMA_PORT}",
  "ollama_external_url": "http://${EXTERNAL_IP}:${OLLAMA_PORT}",
  "agent_url": "http://${SERVER_IP}:${AGENT_PORT}",
  "agent_external_url": "http://${EXTERNAL_IP}:${AGENT_PORT}",
  "model": "${MODEL_TAG}",
  "ports": {
    "ollama": ${OLLAMA_PORT},
    "agent": ${AGENT_PORT}
  }
}
CONNEOF

    print_success "Environment vars exported to /etc/profile.d/aidaptiv-benchmark.sh"
    print_success "Connection info saved to /opt/aidaptiv-agent/connection_info.json"
    print_status "Internal IP: ${SERVER_IP}"
    print_status "External IP: ${EXTERNAL_IP}"
}

# ==============================================================================
# 10. Tool Mapping & Verification
# ==============================================================================
verify_tool_mapping() {
    print_header "10. Tool Mapping & Verification"

    local ALL_OK=true

    # ── Ollama ─────────────────────────────────────────────────────────────
    print_status "Checking Ollama API..."
    if curl -s --max-time 5 http://localhost:${OLLAMA_PORT}/api/tags > /dev/null 2>&1; then
        print_success "Ollama API: http://localhost:${OLLAMA_PORT} ✓"
        MODELS=$(curl -s http://localhost:${OLLAMA_PORT}/api/tags | jq -r '.models[].name' 2>/dev/null | tr '\n' ', ')
        echo "           Models loaded: ${MODELS:-none}"
    else
        print_error "Ollama API: NOT RESPONDING"
        ALL_OK=false
    fi

    # ── Agent ──────────────────────────────────────────────────────────────
    print_status "Checking Benchmark Agent..."
    if curl -s --max-time 5 http://localhost:${AGENT_PORT}/health > /dev/null 2>&1; then
        print_success "Agent API: http://localhost:${AGENT_PORT} ✓"
    else
        print_error "Agent API: NOT RESPONDING"
        ALL_OK=false
    fi

    # ── CLI Tools ──────────────────────────────────────────────────────────
    declare -A TOOLS=(
        ["oha"]="oha --version"
        ["python3"]="python3 --version"
        ["pip3"]="pip3 --version"
        ["jq"]="jq --version"
        ["nvidia-smi"]="nvidia-smi --query-gpu=name --format=csv,noheader"
    )
    for tool in "${!TOOLS[@]}"; do
        if command -v $tool &>/dev/null; then
            local ver=$(${TOOLS[$tool]} 2>&1 | head -1 | tr -d '\n')
            print_success "${tool}: ${ver} ✓"
        else
            print_warning "${tool}: NOT FOUND"
        fi
    done

    # ── Python packages ───────────────────────────────────────────────────
    for pkg in litellm locust llmperf httpx openai; do
        if python3 -c "import ${pkg}" 2>/dev/null; then
            print_success "python:${pkg} ✓"
        else
            print_warning "python:${pkg} NOT INSTALLED"
        fi
    done

    if [ "$ALL_OK" = true ]; then
        print_success "All services and tools are operational!"
    else
        print_warning "Some services are not running — see troubleshooting below"
    fi
}

# ==============================================================================
# 11. Troubleshooting & Auto-Fix
# ==============================================================================
run_troubleshooting() {
    print_header "11. Troubleshooting & Auto-Fix"

    local FIXES_APPLIED=0

    # ── Fix: Ollama not running ────────────────────────────────────────────
    if ! curl -s --max-time 3 http://localhost:${OLLAMA_PORT}/api/tags > /dev/null 2>&1; then
        print_warning "FIX: Ollama is not responding. Attempting restart..."
        sudo systemctl restart ollama 2>/dev/null || true
        sleep 3
        if curl -s --max-time 3 http://localhost:${OLLAMA_PORT}/api/tags > /dev/null 2>&1; then
            print_success "FIXED: Ollama restarted successfully"
            FIXES_APPLIED=$((FIXES_APPLIED+1))
        else
            print_error "FAILED: Ollama still not responding"
            echo "  Manual fix commands:"
            echo "    sudo systemctl status ollama"
            echo "    sudo journalctl -u ollama --no-pager -n 50"
            echo "    sudo systemctl stop ollama && ollama serve &"
            echo "    # If port conflict:"
            echo "    sudo lsof -i :${OLLAMA_PORT}"
            echo "    sudo kill -9 \$(sudo lsof -t -i:${OLLAMA_PORT})"
        fi
    fi

    # ── Fix: Agent not running ─────────────────────────────────────────────
    if ! curl -s --max-time 3 http://localhost:${AGENT_PORT}/health > /dev/null 2>&1; then
        print_warning "FIX: Agent is not responding. Attempting restart..."
        sudo systemctl restart aidaptiv-agent 2>/dev/null || true
        sleep 2
        if curl -s --max-time 3 http://localhost:${AGENT_PORT}/health > /dev/null 2>&1; then
            print_success "FIXED: Agent restarted successfully"
            FIXES_APPLIED=$((FIXES_APPLIED+1))
        else
            print_error "FAILED: Agent still not responding"
            echo "  Manual fix commands:"
            echo "    sudo systemctl status aidaptiv-agent"
            echo "    sudo journalctl -u aidaptiv-agent --no-pager -n 50"
            echo "    # Reinstall agent deps:"
            echo "    cd /opt/aidaptiv-agent && sudo venv/bin/pip install -r requirements.txt"
            echo "    # If port conflict:"
            echo "    sudo lsof -i :${AGENT_PORT}"
            echo "    sudo kill -9 \$(sudo lsof -t -i:${AGENT_PORT})"
            echo "    sudo systemctl restart aidaptiv-agent"
        fi
    fi

    # ── Fix: Ollama not binding to 0.0.0.0 ─────────────────────────────────
    if curl -s --max-time 3 http://localhost:${OLLAMA_PORT}/api/tags > /dev/null 2>&1; then
        local BIND_ADDR=$(ss -tlnp | grep ":${OLLAMA_PORT}" | awk '{print $4}' | head -1)
        if echo "$BIND_ADDR" | grep -q "127.0.0.1"; then
            print_warning "FIX: Ollama bound to localhost only. Rebinding to 0.0.0.0..."
            sudo mkdir -p /etc/systemd/system/ollama.service.d
            sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<'FIXEOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
Environment="OLLAMA_NUM_PARALLEL=4"
Environment="OLLAMA_MAX_LOADED_MODELS=2"
FIXEOF
            sudo systemctl daemon-reload
            sudo systemctl restart ollama
            sleep 3
            print_success "FIXED: Ollama rebound to 0.0.0.0:${OLLAMA_PORT}"
            FIXES_APPLIED=$((FIXES_APPLIED+1))
        fi
    fi

    # ── Fix: Port blocked by iptables ──────────────────────────────────────
    for PORT in ${OLLAMA_PORT} ${AGENT_PORT}; do
        if ! sudo iptables -C INPUT -p tcp --dport ${PORT} -j ACCEPT 2>/dev/null; then
            print_warning "FIX: iptables blocking port ${PORT}. Adding ACCEPT rule..."
            sudo iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT 2>/dev/null || true
            FIXES_APPLIED=$((FIXES_APPLIED+1))
            print_success "FIXED: iptables rule added for port ${PORT}"
        fi
    done

    # ── Fix: Model not loaded ──────────────────────────────────────────────
    if [ -n "${AIDAPTIV_MODEL:-}" ]; then
        if ! ollama list 2>/dev/null | grep -q "${AIDAPTIV_MODEL}"; then
            print_warning "FIX: Model ${AIDAPTIV_MODEL} not found. Attempting pull..."
            ollama pull "${AIDAPTIV_MODEL}" 2>/dev/null && \
                print_success "FIXED: Model ${AIDAPTIV_MODEL} pulled" || \
                print_error "FAILED: Could not pull model. Run manually: ollama pull ${AIDAPTIV_MODEL}"
        fi
    fi

    # ── Summary ────────────────────────────────────────────────────────────
    if [ ${FIXES_APPLIED} -gt 0 ]; then
        print_success "Applied ${FIXES_APPLIED} auto-fix(es)"
    else
        print_success "No issues detected — all services healthy"
    fi

    echo ""
    echo -e "${BOLD}Common manual troubleshooting:${NC}"
    echo "  # View service logs"
    echo "  sudo journalctl -u ollama --no-pager -n 30"
    echo "  sudo journalctl -u aidaptiv-agent --no-pager -n 30"
    echo ""
    echo "  # Restart services"
    echo "  sudo systemctl restart ollama"
    echo "  sudo systemctl restart aidaptiv-agent"
    echo ""
    echo "  # Kill process on port"
    echo "  sudo lsof -i :11434 && sudo kill -9 \$(sudo lsof -t -i:11434)"
    echo "  sudo lsof -i :9100  && sudo kill -9 \$(sudo lsof -t -i:9100)"
    echo ""
    echo "  # Re-pull model"
    echo "  ollama pull <model_tag>"
    echo ""
    echo "  # Check connectivity from benchmark Mac"
    echo "  curl http://<SERVER_IP>:11434/api/tags"
    echo "  curl http://<SERVER_IP>:9100/health"
    echo ""
}

# ==============================================================================
# 12. Final Summary
# ==============================================================================
print_final_summary() {
    local MODEL_TAG="$1"
    local MODEL_DISPLAY="$2"
    local MIN_VRAM="$3"
    local MODEL_FAMILY="$4"
    local MODEL_TASK="$5"

    SERVER_IP=$(hostname -I | awk '{print $1}')
    EXTERNAL_IP=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || echo "${SERVER_IP}")

    echo ""
    print_header "Installation Complete!"
    echo -e "${BOLD}Model:${NC}     ${MODEL_DISPLAY}"
    echo -e "${BOLD}Ollama:${NC}    ${MODEL_TAG}"
    echo -e "${BOLD}Family:${NC}    ${MODEL_FAMILY}"
    echo -e "${BOLD}Task:${NC}      ${MODEL_TASK}"
    echo -e "${BOLD}Min VRAM:${NC}  ${MIN_VRAM}"
    echo ""
    echo -e "${BOLD}Network:${NC}"
    echo "  Internal IP: ${SERVER_IP}"
    echo "  External IP: ${EXTERNAL_IP}"
    echo ""
    echo -e "${BOLD}Port Mapping:${NC}"
    echo "  ┌────────────────────────┬───────┬──────────────────────────────────────┐"
    echo "  │ Service                │ Port  │ URL                                  │"
    echo "  ├────────────────────────┼───────┼──────────────────────────────────────┤"
    echo "  │ Ollama API             │ ${OLLAMA_PORT} │ http://${EXTERNAL_IP}:${OLLAMA_PORT}    │"
    echo "  │ Benchmark Agent        │ ${AGENT_PORT}  │ http://${EXTERNAL_IP}:${AGENT_PORT}      │"
    echo "  └────────────────────────┴───────┴──────────────────────────────────────┘"
    echo ""
    echo -e "${BOLD}Environment Variables (auto-loaded on login):${NC}"
    echo "  AIDAPTIV_OLLAMA_URL=http://${SERVER_IP}:${OLLAMA_PORT}"
    echo "  AIDAPTIV_AGENT_URL=http://${SERVER_IP}:${AGENT_PORT}"
    echo "  AIDAPTIV_MODEL=${MODEL_TAG}"
    echo ""
    echo -e "${BOLD}Add to benchmark.yaml on your Mac:${NC}"
    echo "  servers:"
    echo "    server_new:"
    echo "      name: \"$(hostname) — ${MODEL_DISPLAY}\""
    echo "      ollama_url: \"http://${EXTERNAL_IP}:${OLLAMA_PORT}\""
    echo "      agent_url: \"http://${EXTERNAL_IP}:${AGENT_PORT}\""
    echo "  models:"
    echo "    - \"${MODEL_TAG}\""
    echo ""
    echo -e "${BOLD}Test from your Mac:${NC}"
    echo "  curl http://${EXTERNAL_IP}:${AGENT_PORT}/health"
    echo "  curl http://${EXTERNAL_IP}:${AGENT_PORT}/metrics/gpu"
    echo "  curl http://${EXTERNAL_IP}:${OLLAMA_PORT}/api/generate -d '{\"model\":\"${MODEL_TAG}\",\"prompt\":\"Hello\",\"stream\":false}'"
    echo ""
    echo -e "${BOLD}Connection info file:${NC}"
    echo "  cat /opt/aidaptiv-agent/connection_info.json"
    echo ""
}

# ==============================================================================
# Main Installation Flow
# ==============================================================================
run_full_install() {
    local MODEL_TAG="$1"
    local MODEL_DISPLAY="$2"
    local MIN_VRAM="$3"
    local MODEL_FAMILY="$4"
    local MODEL_TASK="$5"
    local DET_MODEL="${6:-}"

    print_header "aiDaptiv Benchmark — VM Installer"
    echo -e "Model: ${BOLD}${MODEL_DISPLAY}${NC}"
    echo -e "Tag:   ${MODEL_TAG}"
    echo ""

    install_system_deps          # 1. apt packages
    validate_gpu                 # 2. NVIDIA driver/CUDA check
    install_ollama               # 3. Ollama + bind 0.0.0.0
    install_benchmark_tools      # 4. oha, k6, litellm, locust, llmperf
    install_agent                # 5. FastAPI agent on :9100
    configure_firewall           # 6. ufw + iptables + GCP firewall
    pull_ollama_model "${MODEL_TAG}" "${MODEL_DISPLAY}"  # 7. Model download

    if [ -n "${DET_MODEL}" ]; then
        create_deterministic_model "${MODEL_TAG}" "${DET_MODEL}"  # 8. Deterministic variant
    fi

    setup_env_mapping "${MODEL_TAG}"   # 9. Export env vars
    verify_tool_mapping                # 10. Verify all tools
    run_troubleshooting                # 11. Auto-fix any issues
    print_final_summary "${MODEL_TAG}" "${MODEL_DISPLAY}" "${MIN_VRAM}" "${MODEL_FAMILY}" "${MODEL_TASK}"  # 12. Summary
}
