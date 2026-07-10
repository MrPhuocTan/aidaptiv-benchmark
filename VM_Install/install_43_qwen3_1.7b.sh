#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Qwen3-1.7B
# Ollama: qwen3:1.7b
# Family: Alibaba Qwen 3
# Task:   Text Generation
# VRAM:   2 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen3:1.7b" \
    "Qwen3-1.7B" \
    "2 GB" \
    "Alibaba Qwen 3" \
    "Text Generation" \
    "qwen3-deterministic:1.7b"
