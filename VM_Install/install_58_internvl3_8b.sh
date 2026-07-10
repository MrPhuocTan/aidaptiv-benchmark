#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  InternVL3-8B
# Ollama: blaifa/InternVL3:8b
# Family: OpenGVLab InternVL3
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
    "blaifa/InternVL3:8b" \
    "InternVL3-8B" \
    "8 GB" \
    "OpenGVLab InternVL3" \
    "Vision-Language" \
    "blaifa/InternVL3-deterministic:8b"
