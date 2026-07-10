#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  deepseek-llm-7b-chat
# Ollama: deepseek-llm:7b
# Family: DeepSeek
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
    "deepseek-llm:7b" \
    "deepseek-llm-7b-chat" \
    "8 GB" \
    "DeepSeek" \
    "Text Generation" \
    "deepseek-llm-deterministic:7b"
