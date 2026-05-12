#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  Phi-4-Multimodal-Instruct
# Ollama: phi4:latest
# Family: Microsoft Phi-4
# Task:   Vision-Language
# VRAM:   8 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "phi4:latest" \
    "Phi-4-Multimodal-Instruct" \
    "8 GB" \
    "Microsoft Phi-4" \
    "Vision-Language" \
    "phi4-deterministic:latest"
