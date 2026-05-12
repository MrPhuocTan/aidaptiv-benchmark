#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Llama-4-Scout-17B-16E-Instruct
# Ollama: llama4:scout
# Family: Meta Llama 4
# Task:   Text Generation
# VRAM:   24 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "llama4:scout" \
    "Llama-4-Scout-17B-16E-Instruct" \
    "24 GB" \
    "Meta Llama 4" \
    "Text Generation" \
    "llama4-deterministic:scout"
