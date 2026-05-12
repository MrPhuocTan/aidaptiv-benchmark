#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Qwen1.5-72B-Chat
# Ollama: qwen:72b
# Family: Alibaba Qwen
# Task:   Text Generation
# VRAM:   48 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwen:72b" \
    "Qwen1.5-72B-Chat" \
    "48 GB" \
    "Alibaba Qwen" \
    "Text Generation" \
    "qwen-deterministic:72b"
