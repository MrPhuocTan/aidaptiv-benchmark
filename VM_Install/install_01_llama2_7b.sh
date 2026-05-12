#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Llama-2-7b-hf
# Ollama: llama2:7b
# Family: Meta Llama 2
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
    "llama2:7b" \
    "Llama-2-7b-hf" \
    "8 GB" \
    "Meta Llama 2" \
    "Text Generation" \
    "llama2-deterministic:7b"
