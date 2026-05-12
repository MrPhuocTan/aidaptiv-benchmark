#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  deepseek-moe-16b-chat
# Ollama: deepseek-v2:16b
# Family: DeepSeek MoE
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
    "deepseek-v2:16b" \
    "deepseek-moe-16b-chat" \
    "16 GB" \
    "DeepSeek MoE" \
    "Text Generation" \
    "deepseek-v2-deterministic:16b"
