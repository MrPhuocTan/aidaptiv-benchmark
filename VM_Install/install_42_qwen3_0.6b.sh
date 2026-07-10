#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Qwen3-0.6B
# Ollama: qwen3:0.6b
# Family: Alibaba Qwen 3
# Task:   Text Generation
# VRAM:   1 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen3:0.6b" \
    "Qwen3-0.6B" \
    "1 GB" \
    "Alibaba Qwen 3" \
    "Text Generation" \
    "qwen3-deterministic:0.6b"
