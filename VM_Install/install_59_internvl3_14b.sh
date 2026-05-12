#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer
# Model:  InternVL3-14B
# Ollama: blaifa/InternVL3:14b
# Family: OpenGVLab InternVL3
# Task:   Vision-Language
# VRAM:   16 GB minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

run_full_install \
    "blaifa/InternVL3:14b" \
    "InternVL3-14B" \
    "16 GB" \
    "OpenGVLab InternVL3" \
    "Vision-Language" \
    "blaifa/InternVL3-deterministic:14b"
