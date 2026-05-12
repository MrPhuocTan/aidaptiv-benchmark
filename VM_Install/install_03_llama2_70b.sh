#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Llama-2-70b-hf
# Ollama: llama2:70b
# Family: Meta Llama 2
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
    "llama2:70b" \
    "Llama-2-70b-hf" \
    "48 GB" \
    "Meta Llama 2" \
    "Text Generation" \
    "llama2-deterministic:70b"
