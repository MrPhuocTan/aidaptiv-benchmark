#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  GPT-OSS-20B
# Family: GPT OSS
# Task:   Text Generation
# VRAM:   16 GB minimum
#
# NOTE: GPT-OSS models are not available via Ollama.
# This script sets up the environment and placeholder for custom deployment.
# Integration requires a dedicated inference server (e.g., vLLM, TGI).
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

print_header "aiDaptiv Benchmark — GPT-OSS Installer"
echo -e "Model: ${BOLD}GPT-OSS-20B${NC}"
echo -e "Task:  Text Generation"
echo ""

install_system_deps
validate_gpu
install_ollama
install_benchmark_tools
install_agent
configure_firewall

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
print_header "Setup Complete!"
echo -e "${BOLD}Model:${NC}     GPT-OSS-20B"
echo -e "${BOLD}Family:${NC}    GPT OSS"
echo -e "${BOLD}Task:${NC}      Text Generation"
echo -e "${BOLD}Min VRAM:${NC}  16 GB"
echo ""
echo -e "${BOLD}NOTE:${NC} GPT-OSS-20B requires a custom inference server."
echo "      Deploy via vLLM or HuggingFace TGI with the appropriate model weights."
echo ""
echo -e "${BOLD}Port Mapping:${NC}"
echo "  ┌────────────────────────┬───────┐"
echo "  │ Service                │ Port  │"
echo "  ├────────────────────────┼───────┤"
echo "  │ Ollama API             │ 11434 │"
echo "  │ Benchmark Agent        │ 9100  │"
echo "  └────────────────────────┴───────┘"
echo ""
