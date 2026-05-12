#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Mistral-Small-3.1-24B-Instruct
# Ollama: mistral-small:24b
# Family: Mistral AI
# Task:   Text Generation
# VRAM:   16 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "mistral-small:24b" \
    "Mistral-Small-3.1-24B-Instruct" \
    "16 GB" \
    "Mistral AI" \
    "Text Generation" \
    "mistral-small-deterministic:24b"
