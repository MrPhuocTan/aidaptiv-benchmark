#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  InternVL3-1B
# Ollama: internvl3:1b
# Family: OpenGVLab InternVL3
# Task:   Vision-Language
# VRAM:   2 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "internvl3:1b" \
    "InternVL3-1B" \
    "2 GB" \
    "OpenGVLab InternVL3" \
    "Vision-Language" \
    "internvl3-deterministic:1b"
