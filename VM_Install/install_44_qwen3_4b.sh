#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Qwen3-4B
# Ollama: qwen3:4b
# Family: Alibaba Qwen 3
# Task:   Text Generation
# VRAM:   4 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen3:4b" \
    "Qwen3-4B" \
    "4 GB" \
    "Alibaba Qwen 3" \
    "Text Generation" \
    "qwen3-deterministic:4b"
