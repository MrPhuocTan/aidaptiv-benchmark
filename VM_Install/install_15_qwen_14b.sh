#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Qwen1.5-14B-Chat
# Ollama: qwen:14b
# Family: Alibaba Qwen
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
    "qwen:14b" \
    "Qwen1.5-14B-Chat" \
    "16 GB" \
    "Alibaba Qwen" \
    "Text Generation" \
    "qwen-deterministic:14b"
