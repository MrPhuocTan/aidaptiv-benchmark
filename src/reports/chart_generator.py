"""
Generate publication-quality charts for PDF reports.
Styled after financial/trading report aesthetics (clean, professional).
Uses matplotlib for server-side rendering to PNG at 300 DPI.
"""

from pathlib import Path
from typing import Optional
from datetime import datetime

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.dates as mdates
import numpy as np

# ──────────────────────────────────────────────
# Financial-grade color palette
# ──────────────────────────────────────────────
COLORS = {
    "bg":         "#ffffff",
    "bg_dark":    "#ffffff", # No dark mode in PDF
    "text":       "#2D2D2D",
    "text_muted": "#6B6B6B",
    "grid":       "#E8D5A3",
    "grid_dark":  "#E8D5A3",
    # Server palette (Bach Lap Kim)
    "server1":    "#C5A55A",  # Gold
    "server2":    "#2D2D2D",  # Charcoal
    "server3":    "#B8B8B8",  # Silver
    "server4":    "#A68B3C",  # Dark Gold
    # Semantic
    "up":         "#0ECB81",  # Green
    "down":       "#F6465D",  # Red
    "accent":     "#C5A55A",  # Gold accent
}

SERVER_COLORS = [COLORS["server1"], COLORS["server2"], COLORS["server3"], COLORS["server4"]]
PERCENTILE_STYLES = {
    "p50": {"dash": "-",      "width": 2.5, "marker": "o"},
    "p95": {"dash": "--",     "width": 1.8, "marker": "s"},
    "p99": {"dash": (0,(1,1)),"width": 1.4, "marker": "^"},
}


def _apply_style(dark=False):
    """Apply clean financial chart styling."""
    bg = COLORS["bg_dark"] if dark else COLORS["bg"]
    text = "#eaecef" if dark else COLORS["text"]
    grid = COLORS["grid_dark"] if dark else COLORS["grid"]
    
    plt.rcParams.update({
        "figure.facecolor": bg,
        "axes.facecolor": bg,
        "axes.edgecolor": grid,
        "axes.labelcolor": text,
        "axes.labelsize": 11,
        "axes.titlesize": 13,
        "axes.titleweight": "600",
        "text.color": text,
        "xtick.color": text,
        "ytick.color": text,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "grid.color": grid,
        "grid.alpha": 0.5,
        "grid.linewidth": 0.5,
        "font.family": "serif",
        "font.size": 10,
        "legend.fontsize": 9,
        "legend.framealpha": 0.9,
        "figure.dpi": 150,
    })


def render_performance_chart(
    chart_data: dict,
    metric_key: str,
    title: str,
    ylabel: str,
    output_path: str,
    divide_by_concurrency: bool = False,
    width: float = 10.0,
    height: float = 5.0,
    dpi: int = 300,
):
    """
    Render a performance line chart (metric vs concurrency).
    Supports N servers with p50/p95/p99 percentile bands.
    """
    _apply_style()
    
    concurrencies = chart_data.get("concurrencies", [])
    server_labels = chart_data.get("server_labels", {})
    metric_obj = chart_data.get(metric_key, {})
    
    if not concurrencies or not metric_obj:
        return
    
    fig, ax = plt.subplots(figsize=(width, height))
    
    for srv_idx, (srv_key, srv_name) in enumerate(server_labels.items()):
        srv_data = metric_obj.get(srv_key)
        if not srv_data:
            continue
        
        color = SERVER_COLORS[srv_idx % len(SERVER_COLORS)]
        
        for p_key, p_style in PERCENTILE_STYLES.items():
            raw = srv_data.get(p_key, [])
            if not raw:
                continue
            
            x_vals, y_vals = [], []
            for i, v in enumerate(raw):
                if v is not None and i < len(concurrencies):
                    c = concurrencies[i]
                    y = v / c if divide_by_concurrency and c > 0 else v
                    x_vals.append(c)
                    y_vals.append(y)
            
            if x_vals:
                ax.plot(
                    x_vals, y_vals,
                    linestyle=p_style["dash"],
                    linewidth=p_style["width"],
                    marker=p_style["marker"],
                    markersize=5,
                    color=color,
                    label=f"{srv_name} {p_key}",
                    alpha=0.9 if p_key == "p50" else 0.6,
                )
    
    ax.set_xlabel("Concurrency Level", fontweight="500")
    ax.set_ylabel(ylabel, fontweight="500")
    ax.set_title(title, fontweight="600", pad=12)
    ax.set_xscale("log", base=2)
    ax.xaxis.set_major_formatter(ticker.ScalarFormatter())
    ax.xaxis.set_minor_formatter(ticker.NullFormatter())
    ax.set_xticks(concurrencies)
    ax.get_xaxis().set_major_formatter(ticker.FormatStrFormatter('%g'))
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(
        loc="upper left", frameon=True,
        facecolor=COLORS["bg"], edgecolor=COLORS["grid"],
        ncol=len(server_labels),
    )
    
    fig.tight_layout()
    fig.savefig(output_path, dpi=dpi, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close(fig)


def render_comparison_bars(
    summary: dict,
    output_path: str,
    server_labels: dict = None,
    width: float = 10.0,
    height: float = 5.0,
    dpi: int = 300,
):
    """
    Render grouped bar chart comparing server performance metrics.
    Financial-style with clean grid and value annotations.
    """
    _apply_style()
    
    metrics = [
        ("Avg TTFT", "avg_ttft_ms", "ms", True),
        ("Avg TPOT", "avg_tpot_ms", "ms", True),
        ("Avg TPS",  "avg_tps",     "t/s", False),
        ("Avg RPS",  "avg_rps",     "r/s", False),
        ("Avg P99",  "avg_p99_ms",  "ms", True),
    ]
    
    servers = sorted([k for k in summary.keys() if k.startswith("server")])
    if not servers:
        return
    
    labels = [m[0] for m in metrics]
    x = np.arange(len(labels))
    bar_width = 0.8 / len(servers)
    
    fig, ax = plt.subplots(figsize=(width, height))
    
    for i, srv in enumerate(servers):
        vals = [summary[srv].get(m[1], 0) or 0 for m in metrics]
        offset = (i - (len(servers) - 1) / 2) * bar_width
        
        srv_label = server_labels.get(srv, srv) if server_labels else srv
        color = SERVER_COLORS[i % len(SERVER_COLORS)]
        
        bars = ax.bar(
            x + offset, vals, bar_width,
            label=srv_label, color=color,
            edgecolor="white", linewidth=0.5,
            zorder=3,
        )
        
        for bar, val in zip(bars, vals):
            if val:
                ax.annotate(
                    f"{val:.1f}",
                    xy=(bar.get_x() + bar.get_width() / 2, bar.get_height()),
                    xytext=(0, 4), textcoords="offset points",
                    ha="center", va="bottom", fontsize=7.5, color=color,
                    fontweight="500",
                )
    
    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontweight="500")
    ax.set_title("Server Performance Comparison", fontweight="600", pad=12)
    ax.legend(
        loc="upper right", frameon=True,
        facecolor=COLORS["bg"], edgecolor=COLORS["grid"],
    )
    ax.grid(axis="y", alpha=0.3, zorder=0)
    ax.set_axisbelow(True)
    
    fig.tight_layout()
    fig.savefig(output_path, dpi=dpi, bbox_inches="tight")
    plt.close(fig)


def render_hardware_timeline(
    timeline_data: dict,
    metric_key: str,
    title: str,
    ylabel: str,
    output_path: str,
    fill: bool = True,
    width: float = 10.0,
    height: float = 4.5,
    dpi: int = 300,
):
    """
    Render hardware timeline chart with optional area fill.
    Clean financial-grade design with subtle grid.
    """
    _apply_style()
    
    servers = [k for k in timeline_data.keys() if k != "timestamps"]
    if not servers:
        return
    
    fig, ax = plt.subplots(figsize=(width, height))
    
    for srv_idx, srv_key in enumerate(servers):
        srv_data = timeline_data.get(srv_key, {})
        timestamps_str = srv_data.get("timestamps", [])
        values = srv_data.get(metric_key, [])
        
        if not timestamps_str or not values:
            continue
        
        try:
            x = [datetime.fromisoformat(ts) for ts in timestamps_str if ts]
        except Exception:
            x = list(range(len(timestamps_str)))
        
        y = values[:len(x)]
        color = SERVER_COLORS[srv_idx % len(SERVER_COLORS)]
        
        ax.plot(x, y, "-", color=color, linewidth=1.5, label=srv_key, alpha=0.9)
        
        if fill:
            ax.fill_between(x, y, alpha=0.08, color=color)
    
    ax.set_ylabel(ylabel, fontweight="500")
    ax.set_title(title, fontweight="600", pad=12)
    
    if isinstance(x[0], datetime):
        ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
        fig.autofmt_xdate(rotation=30)
    
    ax.grid(True, alpha=0.3)
    ax.legend(
        loc="upper right", frameon=True,
        facecolor=COLORS["bg"], edgecolor=COLORS["grid"],
    )
    
    fig.tight_layout()
    fig.savefig(output_path, dpi=dpi, bbox_inches="tight")
    plt.close(fig)


def render_delta_heatmap(
    comparisons: list,
    output_path: str,
    width: float = 10.0,
    height: float = 6.0,
    dpi: int = 300,
):
    """
    Render a delta heatmap for server comparison metrics.
    Green = improvement, Red = degradation.
    """
    _apply_style()
    
    if not comparisons:
        return
    
    metrics = ["delta_ttft_pct", "delta_tps_pct", "delta_rps_pct", "delta_p99_pct"]
    metric_labels = ["Δ TTFT (%)", "Δ TPS (%)", "Δ RPS (%)", "Δ P99 (%)"]
    # For TTFT and P99, negative = improvement (lower latency)
    # For TPS and RPS, positive = improvement (higher throughput)
    invert = [True, False, False, True]
    
    # Build matrix: rows = comparisons, cols = metrics
    row_labels = []
    data = []
    for c in comparisons[:20]:
        label = f"{c.tool or 'all'} / {c.scenario or 'all'} c={c.concurrency}"
        row_labels.append(label[:35])
        row_data = []
        for metric, inv in zip(metrics, invert):
            val = getattr(c, metric, None) or 0
            display = -val if inv else val  # Normalize: positive = good
            row_data.append(display)
        data.append(row_data)
    
    if not data:
        return
    
    arr = np.array(data)
    
    fig, ax = plt.subplots(figsize=(width, height))
    
    # Custom colormap: red → white → green
    from matplotlib.colors import LinearSegmentedColormap
    cmap = LinearSegmentedColormap.from_list("rg", [COLORS["down"], "#ffffff", COLORS["up"]])
    
    vmax = max(abs(arr.min()), abs(arr.max()), 1)
    im = ax.imshow(arr, cmap=cmap, aspect="auto", vmin=-vmax, vmax=vmax)
    
    ax.set_xticks(range(len(metric_labels)))
    ax.set_xticklabels(metric_labels, fontweight="500")
    ax.set_yticks(range(len(row_labels)))
    ax.set_yticklabels(row_labels, fontsize=7)
    ax.set_title("Server Comparison Delta Analysis", fontweight="600", pad=12)
    
    # Annotate cells
    for i in range(len(row_labels)):
        for j in range(len(metric_labels)):
            val = arr[i, j]
            color = "#ffffff" if abs(val) > vmax * 0.6 else COLORS["text"]
            sign = "+" if val > 0 else ""
            ax.text(j, i, f"{sign}{val:.1f}%", ha="center", va="center",
                    fontsize=7, color=color, fontweight="500")
    
    fig.colorbar(im, ax=ax, label="Improvement %", shrink=0.8)
    fig.tight_layout()
    fig.savefig(output_path, dpi=dpi, bbox_inches="tight")
    plt.close(fig)


def generate_all_pdf_charts(
    chart_data: dict,
    timeline_data: dict,
    summary: dict,
    comparisons: list,
    server_labels: dict,
    output_dir: str,
) -> dict:
    """
    Generate all charts needed for the PDF report.
    Returns dict of chart_name → file_path.
    """
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    
    charts = {}
    
    # Performance charts (TTFT, ITL, TPS, Latency)
    perf_configs = [
        ("ttft",    "Time to First Token by Concurrency",     "TTFT (ms)",          False),
        ("itl",     "Inter-Token Latency by Concurrency",     "Latency (ms)",       False),
        ("tps",     "Tokens per Second per User by Concurrency", "Tokens/sec/user", True),
        ("latency", "Request Latency by Concurrency",         "Latency (ms)",       False),
    ]
    
    for key, title, ylabel, div_conc in perf_configs:
        if chart_data.get(key):
            path = str(out / f"perf_{key}.png")
            render_performance_chart(chart_data, key, title, ylabel, path,
                                     divide_by_concurrency=div_conc)
            charts[f"perf_{key}"] = path
    
    # Comparison bar chart
    if summary and len([k for k in summary if k.startswith("server")]) >= 2:
        path = str(out / "comparison_bars.png")
        render_comparison_bars(summary, path, server_labels=server_labels)
        charts["comparison_bars"] = path
    
    # Hardware timelines
    hw_configs = [
        ("gpu_util_pct",  "GPU Utilization Timeline",  "GPU Util (%)"),
        ("cpu_pct",       "CPU Utilization Timeline",   "CPU (%)"),
        ("ram_used_gb",   "RAM Usage Timeline",         "RAM (GB)"),
        ("vram_used_gb",  "VRAM Usage Timeline",        "VRAM (GB)"),
    ]
    
    if timeline_data:
        for key, title, ylabel in hw_configs:
            has_data = any(
                timeline_data.get(srv, {}).get(key)
                for srv in timeline_data if srv != "timestamps"
            )
            if has_data:
                path = str(out / f"hw_{key}.png")
                render_hardware_timeline(timeline_data, key, title, ylabel, path)
                charts[f"hw_{key}"] = path
    
    # Delta heatmap
    if comparisons and len(comparisons) > 0:
        path = str(out / "delta_heatmap.png")
        render_delta_heatmap(comparisons, path)
        charts["delta_heatmap"] = path
    
    return charts
