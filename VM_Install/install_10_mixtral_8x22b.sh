#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Mixtral-8x22B-Instruct-v0.1
# Ollama: mixtral:8x22b
# Family: Mistral AI
# Task:   Text Generation
# VRAM:   80 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "mixtral:8x22b" \
    "Mixtral-8x22B-Instruct-v0.1" \
    "80 GB" \
    "Mistral AI" \
    "Text Generation" \
    "mixtral-deterministic:8x22b"
