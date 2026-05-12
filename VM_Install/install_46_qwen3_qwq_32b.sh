#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Qwen3-QwQ-32B
# Ollama: qwq:32b
# Family: Alibaba Qwen 3 QwQ
# Task:   Reasoning
# VRAM:   24 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "qwq:32b" \
    "Qwen3-QwQ-32B" \
    "24 GB" \
    "Alibaba Qwen 3 QwQ" \
    "Reasoning" \
    "qwq-deterministic:32b"
