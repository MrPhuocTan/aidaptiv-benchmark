#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  CodeLlama-7b-hf
# Ollama: codellama:7b
# Family: Meta CodeLlama
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
    "codellama:7b" \
    "CodeLlama-7b-hf" \
    "8 GB" \
    "Meta CodeLlama" \
    "Text Generation" \
    "codellama-deterministic:7b"
