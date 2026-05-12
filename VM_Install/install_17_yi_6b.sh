#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Yi-1.5-6B
# Ollama: yi:6b
# Family: 01.AI Yi
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
    "yi:6b" \
    "Yi-1.5-6B" \
    "8 GB" \
    "01.AI Yi" \
    "Text Generation" \
    "yi-deterministic:6b"
