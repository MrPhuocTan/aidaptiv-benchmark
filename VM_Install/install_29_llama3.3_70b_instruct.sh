#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Llama-3.3-70B-Instruct
# Ollama: llama3.3:70b
# Family: Meta Llama 3.3
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
    "llama3.3:70b" \
    "Llama-3.3-70B-Instruct" \
    "48 GB" \
    "Meta Llama 3.3" \
    "Text Generation" \
    "llama3.3-deterministic:70b"
