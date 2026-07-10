#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Qwen2.5-VL-72B-Instruct
# Ollama: qwen2.5vl:72b
# Family: Alibaba Qwen 2.5 VL
# Task:   Vision-Language
# VRAM:   48 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen2.5vl:72b" \
    "Qwen2.5-VL-72B-Instruct" \
    "48 GB" \
    "Alibaba Qwen 2.5 VL" \
    "Vision-Language" \
    "qwen2.5vl-deterministic:72b"
