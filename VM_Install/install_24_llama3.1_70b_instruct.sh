#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  Meta-Llama-3.1-70B-Instruct
# Ollama: llama3.1:70b
# Family: Meta Llama 3.1
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
    "llama3.1:70b" \
    "Meta-Llama-3.1-70B-Instruct" \
    "48 GB" \
    "Meta Llama 3.1" \
    "Text Generation" \
    "llama3.1-deterministic:70b"
