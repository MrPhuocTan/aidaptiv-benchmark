#!/bin/bash
# ==============================================================================
# aiDaptive Benchmark — Model Installer #22
# Model:  whisper-large-v2
# Family: OpenAI Whisper
# Task:   Speech Recognition
# VRAM:   8 GB minimum
#
# NOTE: Whisper is a speech recognition model and cannot be served via Ollama.
# This script installs Whisper via Python (openai-whisper) for local inference.
# Benchmark integration requires a custom adapter (not Ollama API).
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_base_setup.sh"

print_header "aiDaptive Benchmark — Whisper Installer"
echo -e "Model: ${BOLD}whisper-large-v2${NC}"
echo -e "Task:  Speech Recognition"
echo ""

install_system_deps
validate_gpu
install_ollama
install_benchmark_tools
install_agent
configure_firewall

# ── Install Whisper ───────────────────────────────────────────────────────
print_header "7. Installing Whisper (Python)"
pip3 install --quiet --upgrade openai-whisper 2>/dev/null || \
    pip3 install --quiet --user --upgrade openai-whisper
print_success "openai-whisper installed"

# Download the large-v2 model
print_status "Pre-downloading whisper-large-v2 weights..."
python3 -c "import whisper; whisper.load_model('large-v2')" 2>/dev/null && \
    print_success "Whisper large-v2 model cached" || \
    print_warning "Failed to pre-download. Model will download on first use."

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
print_header "Setup Complete!"
echo -e "${BOLD}Model:${NC}     whisper-large-v2"
echo -e "${BOLD}Family:${NC}    OpenAI Whisper"
echo -e "${BOLD}Task:${NC}      Speech Recognition"
echo -e "${BOLD}Min VRAM:${NC}  8 GB"
echo ""
echo -e "${BOLD}NOTE:${NC} Whisper uses a custom Python inference pipeline."
echo "      It is NOT served via Ollama API."
echo "      Use: python3 -c \"import whisper; m=whisper.load_model('large-v2'); print(m.transcribe('audio.wav'))\""
echo ""
echo -e "${BOLD}Port Mapping:${NC}"
echo "  ┌────────────────────────┬───────┐"
echo "  │ Service                │ Port  │"
echo "  ├────────────────────────┼───────┤"
echo "  │ Ollama API             │ 11434 │"
echo "  │ Benchmark Agent        │ 9100  │"
echo "  └────────────────────────┴───────┘"
echo ""
