#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Llama-3.2-1B-Instruct
# Ollama: llama3.2:1b
# Family: Meta Llama 3.2
# Task:   Text Generation
# VRAM:   2 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "llama3.2:1b" \
    "Llama-3.2-1B-Instruct" \
    "2 GB" \
    "Meta Llama 3.2" \
    "Text Generation" \
    "llama3.2-deterministic:1b"
