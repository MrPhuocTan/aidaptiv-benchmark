#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Mistral-7B-Instruct-v0.1
# Ollama: mistral:7b
# Family: Mistral AI
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
    "mistral:7b" \
    "Mistral-7B-Instruct-v0.1" \
    "8 GB" \
    "Mistral AI" \
    "Text Generation" \
    "mistral-deterministic:7b"
