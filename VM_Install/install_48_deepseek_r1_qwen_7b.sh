#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  DeepSeek-R1-Distill-Qwen-7B
# Ollama: deepseek-r1:7b
# Family: DeepSeek R1
# Task:   Reasoning
# VRAM:   8 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "deepseek-r1:7b" \
    "DeepSeek-R1-Distill-Qwen-7B" \
    "8 GB" \
    "DeepSeek R1" \
    "Reasoning" \
    "deepseek-r1-deterministic:7b"
