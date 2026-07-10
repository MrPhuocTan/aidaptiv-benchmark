#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Qwen2.5-14B-Instruct
# Ollama: qwen2.5:14b
# Family: Alibaba Qwen 2.5
# Task:   Text Generation
# VRAM:   16 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen2.5:14b" \
    "Qwen2.5-14B-Instruct" \
    "16 GB" \
    "Alibaba Qwen 2.5" \
    "Text Generation" \
    "qwen2.5-deterministic:14b"
