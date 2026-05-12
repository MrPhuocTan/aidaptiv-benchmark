#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Gemma-3-27B-IT
# Ollama: gemma3:27b
# Family: Google Gemma 3
# Task:   Text Generation
# VRAM:   20 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "gemma3:27b" \
    "Gemma-3-27B-IT" \
    "20 GB" \
    "Google Gemma 3" \
    "Text Generation" \
    "gemma3-deterministic:27b"
