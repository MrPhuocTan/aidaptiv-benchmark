#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  InternVL3-2B
# Ollama: internvl3:2b
# Family: OpenGVLab InternVL3
# Task:   Vision-Language
# VRAM:   4 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "internvl3:2b" \
    "InternVL3-2B" \
    "4 GB" \
    "OpenGVLab InternVL3" \
    "Vision-Language" \
    "internvl3-deterministic:2b"
