#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Qwen1.5-7B-Chat
# Ollama: qwen:7b
# Family: Alibaba Qwen
# Task:   Text Generation
# VRAM:   8 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen:7b" \
    "Qwen1.5-7B-Chat" \
    "8 GB" \
    "Alibaba Qwen" \
    "Text Generation" \
    "qwen-deterministic:7b"
