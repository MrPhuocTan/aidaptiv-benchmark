#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  CodeLlama-70b-hf
# Ollama: codellama:70b
# Family: Meta CodeLlama
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
    "codellama:70b" \
    "CodeLlama-70b-hf" \
    "48 GB" \
    "Meta CodeLlama" \
    "Text Generation" \
    "codellama-deterministic:70b"
