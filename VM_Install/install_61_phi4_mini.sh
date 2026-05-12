#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Phi-4-Mini-Instruct
# Ollama: phi4-mini:latest
# Family: Microsoft Phi-4
# Task:   Text Generation
# VRAM:   4 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "phi4-mini:latest" \
    "Phi-4-Mini-Instruct" \
    "4 GB" \
    "Microsoft Phi-4" \
    "Text Generation" \
    "phi4-mini-deterministic:latest"
