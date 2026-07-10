#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Gemma-3-4B-IT
# Ollama: gemma3:4b
# Family: Google Gemma 3
# Task:   Text Generation
# VRAM:   4 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "gemma3:4b" \
    "Gemma-3-4B-IT" \
    "4 GB" \
    "Google Gemma 3" \
    "Text Generation" \
    "gemma3-deterministic:4b"
