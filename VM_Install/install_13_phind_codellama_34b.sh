#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Phind-CodeLlama-34B-v1
# Ollama: phind-codellama:34b
# Family: Phind
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
    "phind-codellama:34b" \
    "Phind-CodeLlama-34B-v1" \
    "24 GB" \
    "Phind" \
    "Text Generation" \
    "phind-codellama-deterministic:34b"
