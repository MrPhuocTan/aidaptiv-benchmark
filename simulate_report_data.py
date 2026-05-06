"""
Simulate realistic benchmark data for Report Testing.
This creates a full benchmark run with 2 servers, multi-tool results,
hardware snapshots, and server comparisons — enough to exercise
all report and export features.
"""
import random
import sys
from datetime import datetime, timedelta

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Adjust Python path so we can import project modules
sys.path.insert(0, ".")

from src.database.tables import (
    Base,
    BenchmarkRun,
    BenchmarkResultRow,
    HardwareSnapshot,
    ServerComparison,
    PromptLog,
    BenchmarkEvidence,
)

DB_URL = "postgresql://aidaptive:aidaptive2024@localhost:5432/aidaptive_benchmark"

engine = create_engine(DB_URL)
Session = sessionmaker(bind=engine)
session = Session()

# --------------------------------------------------
# Config
# --------------------------------------------------
RUN_ID = "run_sim_20260506_demo"
STARTED = datetime(2026, 5, 6, 8, 0, 0)
DURATION = 3600  # 1h simulated duration

SERVERS = {
    "server1": "35.186.159.250",  # Baseline
    "server2": "34.142.222.133",  # aiDaptive+
}

TOOLS = ["ollama_native", "oha", "litellm"]
SCENARIOS = ["simple_chat", "code_generation", "long_context", "reasoning", "translation"]
MODEL = "llama3.2-deterministic:latest"
CONCURRENCY_LEVELS = [1, 8, 16, 32]
ENV = "lan"

# --------------------------------------------------
# Cleanup previous sim run if exists
# --------------------------------------------------
existing = session.query(BenchmarkRun).filter_by(run_id=RUN_ID).first()
if existing:
    session.delete(existing)
    session.commit()
    print(f"  Deleted previous simulation run: {RUN_ID}")

# --------------------------------------------------
# 1. Create BenchmarkRun
# --------------------------------------------------
run = BenchmarkRun(
    run_id=RUN_ID,
    status="completed",
    started_at=STARTED,
    finished_at=STARTED + timedelta(seconds=DURATION),
    duration_seconds=DURATION,
    suite="concurrency_scaling",
    environment=ENV,
    model=MODEL,
    total_tests=len(TOOLS) * len(SCENARIOS) * len(CONCURRENCY_LEVELS) * 2,
    completed_tests=len(TOOLS) * len(SCENARIOS) * len(CONCURRENCY_LEVELS) * 2,
    failed_tests=0,
    notes="Simulated benchmark data for report testing (2 servers comparison)",
    tags=["simulation", "report-test", "2-server"],
    config_snapshot={
        "suite": "concurrency_scaling",
        "server": "all",
        "environment": ENV,
        "concurrency_levels": CONCURRENCY_LEVELS,
        "servers": list(SERVERS.keys()),
    },
)
session.add(run)
session.flush()

print(f"  Created run: {RUN_ID}")

# --------------------------------------------------
# 2. Create BenchmarkResultRow entries (2 servers × tools × scenarios × concurrencies)
# --------------------------------------------------
result_count = 0
ts = STARTED + timedelta(seconds=10)

for tool in TOOLS:
    for scenario in SCENARIOS:
        for conc in CONCURRENCY_LEVELS:
            for srv_key, srv_ip in SERVERS.items():
                # S2 (aiDaptive+) generally better: lower latency, higher TPS
                is_s2 = (srv_key == "server2")
                
                base_ttft = random.uniform(80, 400)
                base_tps = random.uniform(15, 65)
                base_rps = random.uniform(2, 20) * (conc / 8)
                base_p50 = random.uniform(100, 600)
                base_p95 = base_p50 * random.uniform(1.3, 2.0)
                base_p99 = base_p95 * random.uniform(1.1, 1.5)
                
                if is_s2:
                    # aiDaptive+ is ~15-35% better
                    improvement = random.uniform(0.65, 0.85)
                    base_ttft *= improvement
                    base_tps /= improvement  # higher is better
                    base_rps /= improvement
                    base_p50 *= improvement
                    base_p95 *= improvement
                    base_p99 *= improvement
                
                total_reqs = random.randint(20, 100)
                failed_reqs = random.randint(0, max(1, int(total_reqs * 0.02)))
                success_reqs = total_reqs - failed_reqs
                
                result = BenchmarkResultRow(
                    run_id=RUN_ID,
                    timestamp=ts,
                    server=srv_ip,
                    tool=tool,
                    environment=ENV,
                    scenario=scenario,
                    model=MODEL,
                    concurrency=conc,
                    ttft_ms=round(base_ttft, 3),
                    tpot_ms=round(random.uniform(5, 25), 3),
                    itl_ms=round(random.uniform(3, 18), 3),
                    tps=round(base_tps, 3),
                    rps=round(base_rps, 3),
                    latency_p50_ms=round(base_p50, 3),
                    latency_p95_ms=round(base_p95, 3),
                    latency_p99_ms=round(base_p99, 3),
                    total_tokens=random.randint(500, 5000),
                    total_requests=total_reqs,
                    successful_requests=success_reqs,
                    failed_requests=failed_reqs,
                    error_rate=round(failed_reqs / total_reqs, 4),
                    goodput=round(base_tps * (success_reqs / total_reqs), 3),
                )
                session.add(result)
                result_count += 1
                ts += timedelta(seconds=random.randint(5, 15))

print(f"  Inserted {result_count} benchmark results")

# --------------------------------------------------
# 3. Create HardwareSnapshot entries (timeline data)
# --------------------------------------------------
hw_count = 0
for srv_key, srv_ip in SERVERS.items():
    is_s2 = (srv_key == "server2")
    snap_time = STARTED + timedelta(seconds=30)
    
    while snap_time < STARTED + timedelta(seconds=DURATION):
        gpu_util = random.uniform(60, 95) if not is_s2 else random.uniform(40, 75)
        cpu_pct = random.uniform(30, 70)
        
        snapshot = HardwareSnapshot(
            run_id=RUN_ID,
            timestamp=snap_time,
            server=srv_ip,
            gpu_name="NVIDIA L4" if not is_s2 else "NVIDIA T4",
            gpu_util_pct=round(gpu_util, 1),
            vram_used_gb=round(random.uniform(8, 22), 2),
            vram_total_gb=24.0 if not is_s2 else 16.0,
            gpu_power_watts=round(random.uniform(120, 280), 1),
            gpu_temperature_c=round(random.uniform(55, 82), 1),
            gpu_memory_bandwidth_gbps=round(random.uniform(200, 400), 1),
            cpu_pct=round(cpu_pct, 1),
            ram_used_gb=round(random.uniform(6, 14), 2),
            ram_total_gb=32.0 if not is_s2 else 16.0,
            disk_read_mbps=round(random.uniform(10, 200), 2),
            disk_write_mbps=round(random.uniform(5, 100), 2),
            network_rx_mbps=round(random.uniform(1, 50), 2),
            network_tx_mbps=round(random.uniform(1, 30), 2),
        )
        session.add(snapshot)
        hw_count += 1
        snap_time += timedelta(seconds=random.randint(15, 45))

print(f"  Inserted {hw_count} hardware snapshots")

# --------------------------------------------------
# 4. Create ServerComparison entries
# --------------------------------------------------
comp_count = 0
for tool in TOOLS:
    for scenario in SCENARIOS:
        for conc in CONCURRENCY_LEVELS:
            s1_ttft = random.uniform(150, 400)
            s1_tps = random.uniform(15, 50)
            s1_rps = random.uniform(3, 15)
            s1_p99 = random.uniform(400, 1200)
            
            improvement = random.uniform(0.65, 0.85)
            s2_ttft = s1_ttft * improvement
            s2_tps = s1_tps / improvement
            s2_rps = s1_rps / improvement
            s2_p99 = s1_p99 * improvement
            
            delta_ttft = round(((s2_ttft - s1_ttft) / s1_ttft) * 100, 2)
            delta_tps = round(((s2_tps - s1_tps) / s1_tps) * 100, 2)
            delta_rps = round(((s2_rps - s1_rps) / s1_rps) * 100, 2)
            delta_p99 = round(((s2_p99 - s1_p99) / s1_p99) * 100, 2)
            
            # aiDaptive+ (server2) usually wins on TPS and latency
            winner = "server2" if delta_tps > 0 else "server1"
            
            comp = ServerComparison(
                run_id=RUN_ID,
                environment=ENV,
                scenario=scenario,
                tool=tool,
                concurrency=conc,
                s1_ttft_ms=round(s1_ttft, 2),
                s1_tps=round(s1_tps, 2),
                s1_rps=round(s1_rps, 2),
                s1_p99_ms=round(s1_p99, 2),
                s2_ttft_ms=round(s2_ttft, 2),
                s2_tps=round(s2_tps, 2),
                s2_rps=round(s2_rps, 2),
                s2_p99_ms=round(s2_p99, 2),
                delta_ttft_pct=delta_ttft,
                delta_tps_pct=delta_tps,
                delta_rps_pct=delta_rps,
                delta_p99_pct=delta_p99,
                overall_winner=winner,
            )
            session.add(comp)
            comp_count += 1

print(f"  Inserted {comp_count} server comparisons")

# --------------------------------------------------
# 5. Create sample PromptLogs
# --------------------------------------------------
prompts = [
    "Explain the concept of quantum computing in simple terms.",
    "Write a Python function to sort a list using merge sort.",
    "Summarize the following research paper abstract about deep learning...",
    "Translate the following English text to Vietnamese: 'AI is transforming the world.'",
    "Given the following code, identify and fix the bug in the authentication module.",
    "What are the best practices for deploying machine learning models at scale?",
    "Explain how attention mechanisms work in transformer architectures.",
    "Write a REST API endpoint in FastAPI for user authentication.",
]

prompt_count = 0
for srv_key, srv_ip in SERVERS.items():
    for tool in TOOLS[:2]:  # Subset for brevity
        for i, prompt_text in enumerate(prompts):
            sent = STARTED + timedelta(seconds=60 + i * 10)
            ttft = random.uniform(50, 300)
            tps_val = random.uniform(20, 60)
            tokens = random.randint(50, 500)
            
            log = PromptLog(
                run_id=RUN_ID,
                server=srv_ip,
                tool=tool,
                scenario=SCENARIOS[i % len(SCENARIOS)],
                model=MODEL,
                concurrency=1,
                prompt_index=i,
                prompt_text=prompt_text,
                response_text=f"[Simulated response for: {prompt_text[:50]}...] " * 3,
                sent_at=sent,
                first_token_at=sent + timedelta(milliseconds=ttft),
                completed_at=sent + timedelta(seconds=tokens / tps_val),
                ttft_ms=round(ttft, 2),
                tps=round(tps_val, 2),
                tpot_ms=round(1000 / tps_val, 2),
                tokens_generated=tokens,
                status="success",
            )
            session.add(log)
            prompt_count += 1

print(f"  Inserted {prompt_count} prompt logs")

# --------------------------------------------------
# 6. Create sample BenchmarkEvidence
# --------------------------------------------------
evidence_count = 0
for srv_key, srv_ip in SERVERS.items():
    for tool in TOOLS:
        evidence = BenchmarkEvidence(
            run_id=RUN_ID,
            server=srv_ip,
            scenario="simple_chat",
            concurrency=8,
            tool_name=tool,
            tool_version="1.0.0",
            command_line=f"{tool} --server {srv_ip} --concurrency 8 --scenario simple_chat",
            raw_output=f'{{"status":"ok","tool":"{tool}","server":"{srv_ip}","results":{{"tps":42.5,"ttft_ms":120,"rps":5.2}}}}',
            output_format="json",
            captured_at=STARTED + timedelta(minutes=10),
        )
        session.add(evidence)
        evidence_count += 1

print(f"  Inserted {evidence_count} evidence records")

# --------------------------------------------------
# Commit
# --------------------------------------------------
session.commit()
session.close()

print(f"\n  ✅ Simulation complete! Run ID: {RUN_ID}")
print(f"  View report at: http://35.247.155.44:8443/reports/{RUN_ID}")
