#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Meta-Llama-3.1-8B-Instruct
# Ollama: llama3.1:8b
# Family: Meta Llama 3.1
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
    "llama3.1:8b" \
    "Meta-Llama-3.1-8B-Instruct" \
    "8 GB" \
    "Meta Llama 3.1" \
    "Text Generation" \
    "llama3.1-deterministic:8b"
