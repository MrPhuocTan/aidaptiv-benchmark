#!/bin/bash
# ============================================================================
#  aiDaptiv Benchmark Suite - All In One Installer (Linux)
#
#  Hỗ trợ: Ubuntu, Debian, CentOS, RHEL, Fedora
#
#  Script này sẽ:
#    1. Kiểm tra và cài Docker Engine + Docker Compose nếu chưa có
#    2. Khởi động Docker daemon
#    3. Build Docker image cho ứng dụng
#    4. Chạy docker-compose (app + PostgreSQL)
#    5. Hiển thị thông tin truy cập
#
#  Cách dùng:
#    chmod +x install-linux.sh
#    ./install-linux.sh
#
#  Lưu ý: Script cần quyền sudo để cài Docker
# ============================================================================

set -euo pipefail

# ---- Colors & Helpers ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

info()    { echo -e "${WHITE}[INFO]    $1${NC}"; }
ok()      { echo -e "${GREEN}[✓ OK]    $1${NC}"; }
warn()    { echo -e "${YELLOW}[⚠ WARN]  $1${NC}"; }
err()     { echo -e "${RED}[✗ ERROR] $1${NC}"; }
step()    { echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${WHITE}${BOLD}  $1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
divider() { echo -e "${GRAY}──────────────────────────────────────────────────${NC}"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---- Detect OS ----
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        arm64)   echo "arm64" ;;
        *)       echo "$arch" ;;
    esac
}

DISTRO="$(detect_distro)"
ARCH="$(detect_arch)"

# ---- Đường dẫn project ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ============================================================================
#  Banner
# ============================================================================
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${WHITE}${BOLD}aiDaptiv Benchmark Suite - AIO Installer (Linux)${NC}     ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GRAY}All In One • Docker • Auto Setup${NC}                       ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
info "Distro: $DISTRO | Arch: $ARCH"

# ============================================================================
#  Step 1: Kiểm tra và cài Docker
# ============================================================================
step "Step 1/5 — Kiểm tra Docker Engine"

install_docker_linux() {
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  🔐 YÊU CẦU QUYỀN ADMIN (sudo)                     ║${NC}"
    echo -e "${YELLOW}║                                                       ║${NC}"
    echo -e "${YELLOW}║  Cài đặt Docker Engine cần quyền root/sudo.          ║${NC}"
    echo -e "${YELLOW}║  Vui lòng nhập mật khẩu admin khi được hỏi.         ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Xác nhận sudo access trước
    info "Kiểm tra quyền sudo..."
    if ! sudo -v; then
        err "Không thể lấy quyền sudo. Vui lòng chạy script với user có quyền sudo."
        exit 1
    fi
    ok "Đã xác nhận quyền sudo."

    case "$DISTRO" in
        ubuntu|debian)
            info "Đang cài Docker Engine cho $DISTRO..."
            divider

            # Cài prerequisites
            sudo apt-get update -qq
            sudo apt-get install -y -qq \
                ca-certificates \
                curl \
                gnupg \
                lsb-release >/dev/null

            # Thêm Docker GPG key
            sudo install -m 0755 -d /etc/apt/keyrings
            if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
                curl -fsSL "https://download.docker.com/linux/${DISTRO}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                sudo chmod a+r /etc/apt/keyrings/docker.gpg
            fi

            # Thêm Docker repo
            echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO} \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Cài Docker Engine + Compose plugin
            sudo apt-get update -qq
            sudo apt-get install -y -qq \
                docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin >/dev/null

            ok "Docker Engine đã cài thành công."
            ;;

        centos|rhel|fedora|rocky|almalinux)
            info "Đang cài Docker Engine cho $DISTRO..."
            divider

            # Cài prerequisites
            sudo dnf -y install dnf-plugins-core >/dev/null 2>&1 || \
            sudo yum -y install yum-utils >/dev/null 2>&1

            # Thêm Docker repo
            sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || \
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null

            # Cài Docker Engine
            sudo dnf install -y \
                docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin >/dev/null 2>&1 || \
            sudo yum install -y \
                docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin >/dev/null 2>&1

            ok "Docker Engine đã cài thành công."
            ;;

        *)
            warn "Distro '$DISTRO' không được hỗ trợ cài tự động."
            info "Đang thử cài qua convenience script (get.docker.com)..."

            curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
            sudo sh /tmp/get-docker.sh
            rm -f /tmp/get-docker.sh

            ok "Docker đã cài qua convenience script."
            ;;
    esac

    # Thêm user hiện tại vào group docker
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  👤 THÊM USER VÀO DOCKER GROUP                      ║${NC}"
    echo -e "${YELLOW}║                                                       ║${NC}"
    echo -e "${YELLOW}║  Để chạy Docker không cần sudo mỗi lần.             ║${NC}"
    echo -e "${YELLOW}║  (Có thể yêu cầu mật khẩu admin)                   ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    if ! getent group docker >/dev/null 2>&1; then
        sudo groupadd docker
    fi
    sudo usermod -aG docker "$USER"
    ok "Đã thêm user '$USER' vào group docker."
    warn "Lưu ý: Bạn có thể cần logout/login lại để áp dụng quyền docker."
    info "Script sẽ tiếp tục dùng sudo cho lần chạy này."
}

if has_cmd docker; then
    ok "Docker đã được cài: $(docker --version 2>&1)"
else
    install_docker_linux
fi

# ============================================================================
#  Step 2: Kiểm tra Docker daemon đang chạy
# ============================================================================
step "Step 2/5 — Kiểm tra Docker daemon"

start_docker_daemon() {
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  🔐 KHỞI ĐỘNG DOCKER DAEMON                         ║${NC}"
    echo -e "${YELLOW}║                                                       ║${NC}"
    echo -e "${YELLOW}║  Cần quyền sudo để start systemd service.            ║${NC}"
    echo -e "${YELLOW}║  Vui lòng nhập mật khẩu admin nếu được hỏi.         ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    sudo systemctl start docker
    sudo systemctl enable docker
    ok "Docker daemon đã khởi động và enabled."
}

# Hàm chạy docker (tự thêm sudo nếu cần)
run_docker() {
    if docker info >/dev/null 2>&1; then
        docker "$@"
    else
        sudo docker "$@"
    fi
}

run_compose() {
    if docker compose version >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            docker compose "$@"
        else
            sudo docker compose "$@"
        fi
    elif has_cmd docker-compose; then
        if docker info >/dev/null 2>&1; then
            docker-compose "$@"
        else
            sudo docker-compose "$@"
        fi
    else
        err "Docker Compose không tìm thấy!"
        exit 1
    fi
}

if docker info >/dev/null 2>&1; then
    ok "Docker daemon đang chạy."
elif sudo docker info >/dev/null 2>&1; then
    ok "Docker daemon đang chạy (cần sudo)."
else
    warn "Docker daemon chưa khởi động."
    start_docker_daemon

    # Đợi daemon
    MAX_WAIT=30
    WAITED=0
    while ! sudo docker info >/dev/null 2>&1; do
        if [ $WAITED -ge $MAX_WAIT ]; then
            err "Docker daemon không khởi động được."
            exit 1
        fi
        sleep 2
        WAITED=$((WAITED + 2))
    done
    ok "Docker daemon đang chạy."
fi

# Kiểm tra Docker Compose
if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose: $(docker compose version 2>&1)"
elif has_cmd docker-compose; then
    ok "docker-compose (legacy): $(docker-compose version 2>&1)"
else
    warn "Docker Compose chưa cài. Đang cài Docker Compose plugin..."

    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  🔐 CÀI DOCKER COMPOSE PLUGIN                       ║${NC}"
    echo -e "${YELLOW}║  Cần quyền sudo.                                     ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get install -y -qq docker-compose-plugin >/dev/null
            ;;
        centos|rhel|fedora|rocky|almalinux)
            sudo dnf install -y docker-compose-plugin >/dev/null 2>&1 || \
            sudo yum install -y docker-compose-plugin >/dev/null 2>&1
            ;;
        *)
            # Fallback: tải binary
            COMPOSE_VERSION=$(curl -sf https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
            sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            ;;
    esac
    ok "Docker Compose đã cài."
fi

# ============================================================================
#  Step 3: Chuẩn bị môi trường
# ============================================================================
step "Step 3/5 — Chuẩn bị môi trường"

# Copy .env nếu chưa có
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    ok "Đã tạo file .env từ .env.example"
    info "Bạn có thể chỉnh sửa: $SCRIPT_DIR/.env"
else
    ok "File .env đã tồn tại."
fi

# Copy .dockerignore vào project root nếu chưa có
if [ ! -f "$PROJECT_ROOT/.dockerignore" ]; then
    cp "$SCRIPT_DIR/.dockerignore" "$PROJECT_ROOT/.dockerignore"
    ok "Đã copy .dockerignore vào project root"
fi

divider
info "Project root : $PROJECT_ROOT"
info "AIO dir      : $SCRIPT_DIR"
info "Compose file : $SCRIPT_DIR/docker-compose.yaml"

# ============================================================================
#  Step 4: Build Docker Image & Khởi động
# ============================================================================
step "Step 4/5 — Build Docker Image & Khởi động services"

echo ""
info "Đang build Docker image và khởi động containers..."
info "Lần đầu có thể mất 3-5 phút để tải image và cài dependencies."
echo ""

cd "$PROJECT_ROOT"

# Kiểm tra container cũ
if run_docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "aidaptiv-app"; then
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠  CONTAINERS CŨ ĐÃ TỒN TẠI                       ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "  Rebuild và khởi động lại? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Dừng containers cũ..."
        run_compose -f "$SCRIPT_DIR/docker-compose.yaml" down 2>/dev/null || true
        info "Rebuild..."
        run_compose -f "$SCRIPT_DIR/docker-compose.yaml" up --build -d
    else
        info "Giữ nguyên containers hiện tại. Đảm bảo chúng đang chạy..."
        run_compose -f "$SCRIPT_DIR/docker-compose.yaml" up -d
    fi
else
    run_compose -f "$SCRIPT_DIR/docker-compose.yaml" up --build -d
fi

# ============================================================================
#  Step 5: Xác nhận & Hiển thị thông tin
# ============================================================================
step "Step 5/5 — Kiểm tra trạng thái"

# Đợi app khởi động
info "Đang đợi ứng dụng khởi động..."
APP_PORT=$(grep -oP 'AIDAPTIV_APP_PORT=\K[0-9]+' "$SCRIPT_DIR/.env" 2>/dev/null || echo "8443")
MAX_WAIT=60
WAITED=0

while ! curl -sf "http://localhost:${APP_PORT}/" >/dev/null 2>&1; do
    if [ $WAITED -ge $MAX_WAIT ]; then
        warn "Ứng dụng chưa phản hồi sau ${MAX_WAIT}s. Kiểm tra logs:"
        info "  docker compose -f $SCRIPT_DIR/docker-compose.yaml logs app"
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    printf "\r  ${GRAY}Đang đợi... ${WAITED}s${NC}  "
done
echo ""

# Hiển thị trạng thái containers
divider
info "Trạng thái containers:"
run_compose -f "$SCRIPT_DIR/docker-compose.yaml" ps
divider

# ============================================================================
#  Kết quả
# ============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}${BOLD}✅ CÀI ĐẶT HOÀN TẤT!${NC}                                   ${GREEN}║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}🌐 Web UI:${NC}  ${CYAN}http://localhost:${APP_PORT}${NC}                   ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}🐘 PostgreSQL:${NC} ${CYAN}localhost:5432${NC}                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  ${GRAY}Lệnh hữu ích:${NC}                                         ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Xem logs:${NC}    ${GRAY}docker compose -f AIO/docker-compose.yaml logs -f${NC} ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Dừng:${NC}        ${GRAY}docker compose -f AIO/docker-compose.yaml down${NC}   ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Khởi động:${NC}   ${GRAY}docker compose -f AIO/docker-compose.yaml up -d${NC}  ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Rebuild:${NC}     ${GRAY}docker compose -f AIO/docker-compose.yaml up --build -d${NC} ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
