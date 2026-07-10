"""
Generate LaTeX-based PDF reports for benchmark runs.
Uses Jinja2 to render LaTeX templates, matplotlib for charts,
and pdflatex to compile the final PDF.
"""

import io
import os
import shutil
import subprocess
import tempfile
import logging
from pathlib import Path
from typing import Optional

import jinja2

from src.time_utils import get_local_time
from src.reports.chart_generator import generate_all_pdf_charts

logger = logging.getLogger(__name__)

# Path to the LaTeX template
TEMPLATE_DIR = Path(__file__).parent
TEMPLATE_FILE = "report_template.tex"


def _escape_latex(text: str) -> str:
    """Escape special LaTeX characters in text."""
    if not text:
        return ""
    special = {
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
    }
    result = str(text)
    # Handle backslash first
    result = result.replace('\\', r'\textbackslash{}')
    for char, replacement in special.items():
        result = result.replace(char, replacement)
    return result


def _safe_fmt(val, fmt=".2f", suffix=""):
    """Safely format a numeric value for LaTeX."""
    if val is None:
        return "--"
    try:
        return f"{val:{fmt}}{suffix}"
    except (ValueError, TypeError):
        return str(val)


def _build_template_context(
    run,
    report_data: dict,
    chart_data: dict,
    timeline_data: dict,
    comparisons: list,
    charts: dict,
) -> dict:
    """Build the complete Jinja2 context for the LaTeX template."""
    
    metadata = report_data.get("metadata", {})
    hw_summary = report_data.get("hardware_summary", {})
    breakdown = report_data.get("breakdown", {})
    server_labels = metadata.get("server_labels", {})
    
    # Basic info
    ctx = {
        "run_id": _escape_latex(run.run_id),
        "report_date": get_local_time().strftime("%Y-%m-%d %H:%M"),
        "test_suite": _escape_latex((run.suite or "").replace("_", " ").title()),
        "model": _escape_latex(run.model or "N/A"),
        "server_count": metadata.get("server_count", 0),
        "total_tests": run.total_tests or 0,
        "total_requests": metadata.get("total_requests", 0),
        "duration": _safe_fmt(run.duration_seconds, ".1f", "s") if run.duration_seconds else "N/A",
        "started_at": run.started_at.strftime("%Y-%m-%d %H:%M:%S") if run.started_at else "N/A",
        "finished_at": run.finished_at.strftime("%Y-%m-%d %H:%M:%S") if run.finished_at else "N/A",
        "servers_list": _escape_latex(", ".join(metadata.get("servers", []))),
        "tools_list": _escape_latex(", ".join(metadata.get("tools", []))),
        "scenarios_list": _escape_latex(", ".join(metadata.get("scenarios", []))),
        "concurrencies_list": ", ".join(str(c) for c in metadata.get("concurrencies", [])),
        "prompt_set": _escape_latex(
            run.config_snapshot.get("prompt_set", "Default") if run.config_snapshot else "Default"
        ),
        "charts": charts,
        "chart_data": chart_data,
    }
    
    # Winner
    winner = None
    if comparisons:
        from collections import Counter
        winners = Counter(c.overall_winner for c in comparisons if c.overall_winner and c.overall_winner != "tie")
        if winners:
            winner_key = winners.most_common(1)[0][0]
            winner = _escape_latex(server_labels.get(winner_key, winner_key))
    ctx["winner"] = winner
    
    # Comparison data
    ctx["has_comparison"] = len(server_labels) >= 2
    
    if comparisons:
        comp_table = []
        for c in comparisons:
            comp_table.append({
                "tool": _escape_latex(c.tool or "all"),
                "scenario": _escape_latex(c.scenario or "all"),
                "concurrency": c.concurrency or "--",
                "s1_ttft": _safe_fmt(c.s1_ttft_ms),
                "s1_tps": _safe_fmt(c.s1_tps),
                "s1_rps": _safe_fmt(c.s1_rps),
                "s1_p99": _safe_fmt(c.s1_p99_ms),
                "s2_ttft": _safe_fmt(c.s2_ttft_ms),
                "s2_tps": _safe_fmt(c.s2_tps),
                "s2_rps": _safe_fmt(c.s2_rps),
                "s2_p99": _safe_fmt(c.s2_p99_ms),
                "winner": _escape_latex(c.overall_winner or "tie"),
            })
        ctx["comparison_table"] = comp_table
    else:
        ctx["comparison_table"] = None
    
    # Hardware specs
    ctx["has_hardware"] = bool(hw_summary)
    hw_servers = []
    for srv_key in sorted(hw_summary.keys()):
        hw_servers.append(_escape_latex(server_labels.get(srv_key, srv_key)))
    ctx["hw_servers"] = hw_servers
    
    if hw_summary:
        gpu_metrics = [
            ("GPU Model",      "gpu_name",          None),
            ("GPU Util (avg)", "gpu_util_avg",       ".1f%%"),
            ("GPU Util (max)", "gpu_util_max",       ".1f%%"),
            ("VRAM Used (avg)","vram_used_avg_gb",   ".2f GB"),
            ("VRAM Total",     "vram_total_gb",      ".2f GB"),
            ("Power (avg)",    "gpu_power_avg_w",    ".1f W"),
            ("Power (max)",    "gpu_power_max_w",    ".1f W"),
            ("Temp (avg)",     "gpu_temp_avg_c",     ".1f°C"),
            ("Temp (max)",     "gpu_temp_max_c",     ".1f°C"),
        ]
        cpu_metrics = [
            ("CPU (avg)",      "cpu_avg_pct",        ".1f%%"),
            ("CPU (max)",      "cpu_max_pct",        ".1f%%"),
            ("RAM Used (avg)", "ram_used_avg_gb",     ".2f GB"),
            ("RAM Total",      "ram_total_gb",        ".2f GB"),
        ]
        disk_metrics = [
            ("Disk Read (avg)",  "disk_read_avg_mbps",  ".2f MB/s"),
            ("Disk Write (avg)", "disk_write_avg_mbps", ".2f MB/s"),
        ]
        
        def build_hw_rows(metric_list):
            rows = []
            for label, key, fmt in metric_list:
                values = []
                for srv_key in sorted(hw_summary.keys()):
                    hw = hw_summary[srv_key]
                    val = hw.get(key)
                    if fmt is None:
                        values.append(_escape_latex(str(val or "N/A")))
                    elif val is not None:
                        try:
                            # Handle %% in format string
                            if fmt.endswith("%%"):
                                values.append(f"{val:{fmt[:-1]}}")
                            else:
                                parts = fmt.split(" ", 1)
                                num_fmt = parts[0]
                                unit = parts[1] if len(parts) > 1 else ""
                                values.append(f"{val:{num_fmt}} {unit}".strip())
                        except (ValueError, TypeError):
                            values.append(_escape_latex(str(val)))
                    else:
                        values.append("N/A")
                rows.append({"label": _escape_latex(label), "values": values})
            return rows
        
        ctx["hardware_specs_table"] = {
            "gpu": build_hw_rows(gpu_metrics),
            "cpu": build_hw_rows(cpu_metrics),
            "disk": build_hw_rows(disk_metrics),
        }
    else:
        ctx["hardware_specs_table"] = None
    
    # Breakdown table
    if breakdown:
        breakdown_rows = []
        for tool, scen_dict in breakdown.items():
            for scenario, srv_dict in scen_dict.items():
                cells = []
                for srv_key in sorted(server_labels.keys()):
                    s = srv_dict.get(srv_key, {})
                    cells.append({
                        "tps": _safe_fmt(s.get("tps")),
                        "ttft": _safe_fmt(s.get("ttft_ms")),
                        "tpot": _safe_fmt(s.get("tpot_ms")),
                        "rps": _safe_fmt(s.get("rps")),
                        "p99": _safe_fmt(s.get("latency_p99_ms")),
                        "error": _safe_fmt(s.get("error_rate"), ".0f", r"\%"),
                    })
                breakdown_rows.append({
                    "tool": _escape_latex(tool),
                    "scenario": _escape_latex(scenario),
                    "cells": cells,
                })
        ctx["breakdown_table"] = breakdown_rows
    else:
        ctx["breakdown_table"] = None
    
    return ctx


def _find_xelatex() -> Optional[str]:
    """Find xelatex binary on the system."""
    result = shutil.which("xelatex")
    if result:
        return result
    # Common paths
    for path in ["/usr/bin/xelatex", "/usr/local/bin/xelatex",
                 "/Library/TeX/texbin/xelatex", "/opt/homebrew/bin/xelatex"]:
        if os.path.isfile(path):
            return path
    return None


def generate_benchmark_pdf(
    run,
    report_data: dict,
    chart_data: dict,
    timeline_data: dict,
    comparisons: list,
    summary_stats: dict = None,
) -> Optional[bytes]:
    """
    Generate a complete PDF benchmark report.
    
    Args:
        run: BenchmarkRun ORM object
        report_data: Output of get_detailed_report_stats()
        chart_data: Output of get_dashboard_chart_data()
        timeline_data: Output of get_timeline_chart_data()
        comparisons: List of ServerComparison objects
        summary_stats: Output of get_run_summary_stats()
    
    Returns:
        PDF file as bytes, or None on failure
    """
    xelatex = _find_xelatex()
    if not xelatex:
        logger.error("xelatex not found. Please install TeX Live and xeCJK.")
        return None
    
    # Create temp dir for build
    tmpdir = tempfile.mkdtemp(prefix="aidaptiv_report_")
    
    try:
        metadata = report_data.get("metadata", {})
        server_labels = metadata.get("server_labels", {})
        
        # Step 1: Generate charts
        charts_dir = os.path.join(tmpdir, "charts")
        charts = generate_all_pdf_charts(
            chart_data=chart_data or {},
            timeline_data=timeline_data or {},
            summary=summary_stats or {},
            comparisons=comparisons or [],
            server_labels=server_labels,
            output_dir=charts_dir,
        )
        
        # Step 2: Build template context
        ctx = _build_template_context(
            run=run,
            report_data=report_data,
            chart_data=chart_data or {},
            timeline_data=timeline_data or {},
            comparisons=comparisons or [],
            charts=charts,
        )
        
        # Step 3: Render LaTeX template with Jinja2
        latex_env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(str(TEMPLATE_DIR)),
            block_start_string=r'\BLOCK{',
            block_end_string='}',
            variable_start_string=r'\VAR{',
            variable_end_string='}',
            comment_start_string=r'\#{',
            comment_end_string='}',
            line_statement_prefix='%%',
            line_comment_prefix='%#',
            trim_blocks=True,
            lstrip_blocks=True,
            autoescape=False,
        )
        
        template = latex_env.get_template(TEMPLATE_FILE)
        rendered_tex = template.render(**ctx)
        
        # Write rendered .tex to tmpdir
        tex_path = os.path.join(tmpdir, "report.tex")
        with open(tex_path, "w", encoding="utf-8") as f:
            f.write(rendered_tex)
        
        # Step 4: Compile LaTeX → PDF (2 passes for TOC/references)
        for pass_num in range(2):
            result = subprocess.run(
                [
                    xelatex,
                    "-interaction=nonstopmode",
                    "-halt-on-error",
                    "-output-directory", tmpdir,
                    tex_path,
                ],
                capture_output=True,
                text=True,
                timeout=120,
                cwd=tmpdir,
            )
            
            if result.returncode != 0 and pass_num == 1:
                logger.error(f"xelatex failed (pass {pass_num + 1}):\n{result.stdout[-3000:]}")
                logger.error(f"STDERR: {result.stderr[-1000:]}")
                # Try to return partial PDF if it exists
                pdf_path = os.path.join(tmpdir, "report.pdf")
                if os.path.isfile(pdf_path):
                    logger.warning("Returning partial PDF despite errors")
                else:
                    return None
        
        # Step 5: Read the PDF
        pdf_path = os.path.join(tmpdir, "report.pdf")
        if not os.path.isfile(pdf_path):
            logger.error("PDF file not generated")
            return None
        
        with open(pdf_path, "rb") as f:
            return f.read()
    
    except subprocess.TimeoutExpired:
        logger.error("xelatex compilation timed out (120s)")
        return None
    except Exception as e:
        logger.error(f"PDF generation failed: {e}", exc_info=True)
        return None
    finally:
        # Cleanup
        try:
            shutil.rmtree(tmpdir, ignore_errors=True)
        except Exception:
            pass


def check_latex_available() -> bool:
    """Check if xelatex is available on the system."""
    return _find_xelatex() is not None