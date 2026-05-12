#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  DeepSeek-R1-Distill-Qwen-4B
# Ollama: deepseek-r1:8b
# Family: DeepSeek R1
# Task:   Reasoning
# VRAM:   4 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "deepseek-r1:8b" \
    "DeepSeek-R1-Distill-Qwen-4B" \
    "4 GB" \
    "DeepSeek R1" \
    "Reasoning" \
    "deepseek-r1-deterministic:8b"
