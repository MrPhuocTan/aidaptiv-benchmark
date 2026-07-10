#!/usr/bin/env python3
"""Generate sample PDF report with mock data using local xelatex."""
import sys, os, random
from datetime import timedelta
from types import SimpleNamespace

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Patch the xelatex finder to use our local install
XELATEX_PATH = "/Users/mrtun/.local/texlive/usr/local/texlive/2026basic/bin/universal-darwin/xelatex"

from src.reports import pdf_generator
_original_find = pdf_generator._find_xelatex
def _patched_find():
    if os.path.isfile(XELATEX_PATH):
        return XELATEX_PATH
    return _original_find()
pdf_generator._find_xelatex = _patched_find

from src.reports.pdf_generator import generate_benchmark_pdf
from src.time_utils import get_local_time


def build_mock():
    now = get_local_time()
    random.seed(42)
    run = SimpleNamespace(
        run_id="BENCH-20260622-0930", status="completed", suite="full_benchmark",
        model="Qwen2.5-72B-Instruct-AWQ", environment="lan", total_tests=36,
        completed_tests=36, notes="Sample", tags=["sample"],
        started_at=now - timedelta(hours=2, minutes=15), finished_at=now,
        duration_seconds=8100.0,
        config_snapshot={"suite": "full_benchmark", "prompt_set": "Vietnamese QA v2",
                         "servers": ["192.168.1.10", "192.168.1.20"]},
    )
    report_data = {
        "metadata": {
            "tools": ["litellm", "ollama_native", "oha"],
            "scenarios": ["short_answer", "long_generation", "code_generation"],
            "servers": ["192.168.1.10", "192.168.1.20"],
            "models": ["Qwen2.5-72B-Instruct-AWQ"], "total_requests": 4320,
            "server_count": 2, "concurrencies": [1, 8, 16, 32, 64],
            "server_labels": {"server1": "192.168.1.10", "server2": "192.168.1.20"},
        },
        "breakdown": {
            "litellm": {
                "short_answer": {
                    "server1": {"tps": 42.15, "ttft_ms": 128.5, "tpot_ms": 23.4, "rps": 8.2, "latency_p99_ms": 312.8, "error_rate": 0, "total_requests": 240},
                    "server2": {"tps": 38.90, "ttft_ms": 145.2, "tpot_ms": 25.1, "rps": 7.6, "latency_p99_ms": 356.4, "error_rate": 0.5, "total_requests": 240},
                },
                "long_generation": {
                    "server1": {"tps": 35.20, "ttft_ms": 185.3, "tpot_ms": 28.7, "rps": 3.1, "latency_p99_ms": 1523.6, "error_rate": 1.2, "total_requests": 240},
                    "server2": {"tps": 31.45, "ttft_ms": 210.8, "tpot_ms": 31.2, "rps": 2.8, "latency_p99_ms": 1789.2, "error_rate": 2.1, "total_requests": 240},
                },
                "code_generation": {
                    "server1": {"tps": 38.90, "ttft_ms": 152.1, "tpot_ms": 25.8, "rps": 5.4, "latency_p99_ms": 823.5, "error_rate": 0.3, "total_requests": 240},
                    "server2": {"tps": 34.60, "ttft_ms": 178.5, "tpot_ms": 28.9, "rps": 4.9, "latency_p99_ms": 945.7, "error_rate": 0.8, "total_requests": 240},
                },
            },
            "ollama_native": {
                "short_answer": {
                    "server1": {"tps": 45.30, "ttft_ms": 112.3, "tpot_ms": 21.8, "rps": 9.1, "latency_p99_ms": 285.6, "error_rate": 0},
                    "server2": {"tps": 41.20, "ttft_ms": 132.6, "tpot_ms": 23.5, "rps": 8.3, "latency_p99_ms": 325.8, "error_rate": 0},
                },
                "long_generation": {
                    "server1": {"tps": 37.80, "ttft_ms": 168.5, "tpot_ms": 26.4, "rps": 3.4, "latency_p99_ms": 1385.2, "error_rate": 0.8},
                    "server2": {"tps": 33.90, "ttft_ms": 195.2, "tpot_ms": 29.5, "rps": 3.0, "latency_p99_ms": 1625.8, "error_rate": 1.5},
                },
                "code_generation": {
                    "server1": {"tps": 40.50, "ttft_ms": 138.7, "tpot_ms": 24.6, "rps": 5.8, "latency_p99_ms": 756.3, "error_rate": 0},
                    "server2": {"tps": 36.80, "ttft_ms": 162.3, "tpot_ms": 27.1, "rps": 5.2, "latency_p99_ms": 878.5, "error_rate": 0.4},
                },
            },
            "oha": {
                "short_answer": {
                    "server1": {"tps": 44.10, "ttft_ms": 118.9, "tpot_ms": 22.5, "rps": 8.8, "latency_p99_ms": 298.2, "error_rate": 0},
                    "server2": {"tps": 40.30, "ttft_ms": 138.4, "tpot_ms": 24.2, "rps": 8.0, "latency_p99_ms": 342.1, "error_rate": 0},
                },
                "long_generation": {
                    "server1": {"tps": 36.50, "ttft_ms": 175.8, "tpot_ms": 27.3, "rps": 3.2, "latency_p99_ms": 1456.8, "error_rate": 1.0},
                    "server2": {"tps": 32.80, "ttft_ms": 202.5, "tpot_ms": 30.5, "rps": 2.9, "latency_p99_ms": 1698.5, "error_rate": 1.8},
                },
                "code_generation": {
                    "server1": {"tps": 39.70, "ttft_ms": 145.2, "tpot_ms": 25.2, "rps": 5.6, "latency_p99_ms": 789.4, "error_rate": 0.2},
                    "server2": {"tps": 35.90, "ttft_ms": 170.8, "tpot_ms": 27.8, "rps": 5.0, "latency_p99_ms": 912.3, "error_rate": 0.6},
                },
            },
        },
        "hardware_summary": {
            "server1": {"gpu_name": "NVIDIA RTX 4090 24GB", "gpu_util_avg": 87.3, "gpu_util_max": 99.8,
                "vram_used_avg_gb": 21.5, "vram_total_gb": 24.0, "gpu_power_avg_w": 285.6,
                "gpu_power_max_w": 350.0, "gpu_temp_avg_c": 72.5, "gpu_temp_max_c": 83.0,
                "cpu_avg_pct": 35.2, "cpu_max_pct": 68.5, "ram_used_avg_gb": 28.4, "ram_total_gb": 64.0,
                "disk_read_avg_mbps": 125.3, "disk_write_avg_mbps": 42.8},
            "server2": {"gpu_name": "NVIDIA RTX 3090 24GB", "gpu_util_avg": 92.1, "gpu_util_max": 100.0,
                "vram_used_avg_gb": 22.8, "vram_total_gb": 24.0, "gpu_power_avg_w": 310.2,
                "gpu_power_max_w": 350.0, "gpu_temp_avg_c": 78.3, "gpu_temp_max_c": 88.0,
                "cpu_avg_pct": 42.8, "cpu_max_pct": 75.2, "ram_used_avg_gb": 32.1, "ram_total_gb": 64.0,
                "disk_read_avg_mbps": 98.7, "disk_write_avg_mbps": 35.2},
        },
    }
    concurrencies = [1, 8, 16, 32, 64]
    chart_data = {
        "concurrencies": concurrencies,
        "server_labels": {"server1": "192.168.1.10", "server2": "192.168.1.20"},
        "ttft": {
            "server1": {"p50": [52.3, 98.5, 145.2, 215.8, 385.6], "p95": [68.5, 125.3, 185.6, 312.5, 528.4], "p99": [85.2, 152.8, 228.5, 425.3, 725.8]},
            "server2": {"p50": [58.6, 112.3, 168.5, 248.2, 435.2], "p95": [75.2, 142.5, 215.8, 358.6, 598.5], "p99": [95.8, 178.5, 265.2, 485.6, 812.3]},
        },
        "itl": {
            "server1": {"p50": [18.5, 22.3, 25.8, 31.2, 42.5], "p95": [18.5, 22.3, 25.8, 31.2, 42.5], "p99": [18.5, 22.3, 25.8, 31.2, 42.5]},
            "server2": {"p50": [21.2, 25.8, 29.5, 35.6, 48.2], "p95": [21.2, 25.8, 29.5, 35.6, 48.2], "p99": [21.2, 25.8, 29.5, 35.6, 48.2]},
        },
        "tps": {
            "server1": {"p50": [48.5, 380.2, 720.5, 1285.6, 2150.8], "p95": [45.2, 352.8, 678.5, 1185.2, 1985.6], "p99": [42.8, 325.6, 625.8, 1085.3, 1825.2]},
            "server2": {"p50": [43.2, 342.5, 648.2, 1152.8, 1925.6], "p95": [40.5, 315.8, 598.5, 1052.3, 1785.2], "p99": [38.2, 292.5, 552.8, 958.5, 1625.8]},
        },
        "latency": {
            "server1": {"p50": [125.3, 185.6, 285.2, 452.8, 825.6], "p95": [185.2, 298.5, 456.8, 725.3, 1285.6], "p99": [225.8, 385.6, 585.2, 985.6, 1685.2]},
            "server2": {"p50": [142.5, 215.8, 325.6, 512.3, 945.8], "p95": [215.6, 345.2, 528.5, 852.6, 1456.8], "p99": [268.5, 445.2, 685.6, 1125.8, 1925.6]},
        },
    }
    num_points = 50
    base_time = now - timedelta(hours=2)
    timestamps = [(base_time + timedelta(minutes=i*2.5)).isoformat() for i in range(num_points)]
    timeline_data = {
        "timestamps": timestamps,
        "server1": {"timestamps": timestamps, "gpu_util_pct": [random.uniform(75, 99) for _ in range(num_points)],
            "cpu_pct": [random.uniform(25, 65) for _ in range(num_points)],
            "vram_used_gb": [random.uniform(20, 23) for _ in range(num_points)],
            "ram_used_gb": [random.uniform(26, 32) for _ in range(num_points)]},
        "server2": {"timestamps": timestamps, "gpu_util_pct": [random.uniform(82, 100) for _ in range(num_points)],
            "cpu_pct": [random.uniform(32, 72) for _ in range(num_points)],
            "vram_used_gb": [random.uniform(21, 24) for _ in range(num_points)],
            "ram_used_gb": [random.uniform(29, 36) for _ in range(num_points)]},
    }
    comparisons = []
    for tool in ["litellm", "ollama_native", "oha"]:
        for scenario in ["short_answer", "long_generation", "code_generation"]:
            for c in [1, 8, 16, 32, 64]:
                s1 = report_data["breakdown"][tool][scenario]["server1"]
                s2 = report_data["breakdown"][tool][scenario]["server2"]
                comparisons.append(SimpleNamespace(
                    tool=tool, scenario=scenario, concurrency=c,
                    s1_ttft_ms=round(s1["ttft_ms"]*(1+c*0.02),2), s1_tps=round(s1["tps"]*c*0.95,2),
                    s1_rps=round(s1["rps"]*c*0.9,2), s1_p99_ms=round(s1["latency_p99_ms"]*(1+c*0.015),2),
                    s2_ttft_ms=round(s2["ttft_ms"]*(1+c*0.025),2), s2_tps=round(s2["tps"]*c*0.92,2),
                    s2_rps=round(s2["rps"]*c*0.88,2), s2_p99_ms=round(s2["latency_p99_ms"]*(1+c*0.018),2),
                    overall_winner="server1",
                ))
    summary = {
        "server1": {"avg_ttft_ms": 142.5, "avg_tpot_ms": 24.2, "avg_tps": 40.5, "avg_rps": 5.8,
            "avg_p50_ms": 285.6, "avg_p95_ms": 456.8, "avg_p99_ms": 625.3},
        "server2": {"avg_ttft_ms": 165.8, "avg_tpot_ms": 27.5, "avg_tps": 36.2, "avg_rps": 5.1,
            "avg_p50_ms": 328.5, "avg_p95_ms": 528.6, "avg_p99_ms": 725.8},
    }
    return run, report_data, chart_data, timeline_data, comparisons, summary

if __name__ == "__main__":
    print("=" * 60)
    print("  aiDaptiv Benchmark - PDF Report Generator")
    print("=" * 60)
    print(f"  xelatex: {XELATEX_PATH}")
    run, report_data, chart_data, timeline_data, comparisons, summary = build_mock()
    print("→ Generating charts + LaTeX + PDF...")
    pdf = generate_benchmark_pdf(run=run, report_data=report_data, chart_data=chart_data,
                                  timeline_data=timeline_data, comparisons=comparisons, summary_stats=summary)
    if pdf:
        path = os.path.join(os.path.dirname(__file__), "sample_benchmark_report.pdf")
        with open(path, "wb") as f:
            f.write(pdf)
        print(f"\n✅ PDF: {path} ({len(pdf)/1024:.1f} KB)")
    else:
        print("\n❌ PDF generation failed")
        sys.exit(1)
