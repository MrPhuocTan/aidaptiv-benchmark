#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Mixtral-8x7B-Instruct-v0.1
# Ollama: mixtral:8x7b
# Family: Mistral AI
# Task:   Text Generation
# VRAM:   32 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "mixtral:8x7b" \
    "Mixtral-8x7B-Instruct-v0.1" \
    "32 GB" \
    "Mistral AI" \
    "Text Generation" \
    "mixtral-deterministic:8x7b"
