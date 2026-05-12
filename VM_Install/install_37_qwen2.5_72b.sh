#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Qwen2.5-72B-Instruct
# Ollama: qwen2.5:72b
# Family: Alibaba Qwen 2.5
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
    "qwen2.5:72b" \
    "Qwen2.5-72B-Instruct" \
    "48 GB" \
    "Alibaba Qwen 2.5" \
    "Text Generation" \
    "qwen2.5-deterministic:72b"
