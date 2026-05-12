#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  deepseek-llm-67b-chat
# Ollama: deepseek-llm:67b
# Family: DeepSeek
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
    "deepseek-llm:67b" \
    "deepseek-llm-67b-chat" \
    "48 GB" \
    "DeepSeek" \
    "Text Generation" \
    "deepseek-llm-deterministic:67b"
