#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Qwen2.5-VL-32B-Instruct
# Ollama: qwen2.5vl:32b
# Family: Alibaba Qwen 2.5 VL
# Task:   Vision-Language
# VRAM:   24 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen2.5vl:32b" \
    "Qwen2.5-VL-32B-Instruct" \
    "24 GB" \
    "Alibaba Qwen 2.5 VL" \
    "Vision-Language" \
    "qwen2.5vl-deterministic:32b"
