#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Generate All Model Installers
# Run this script ONCE to generate all model-specific install scripts
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Model definitions: FILENAME|OLLAMA_TAG|DISPLAY_NAME|MIN_VRAM|FAMILY|TASK
# ── Legacy Models (kept for backward compatibility) ──────────────────────────
MODELS=(
    "install_01_llama2_7b.sh|llama2:7b|Llama-2-7b-hf|8 GB|Meta Llama 2|Text Generation"
    "install_02_llama2_13b.sh|llama2:13b|Llama-2-13b-hf|16 GB|Meta Llama 2|Text Generation"
    "install_03_llama2_70b.sh|llama2:70b|Llama-2-70b-hf|48 GB|Meta Llama 2|Text Generation"
    "install_04_llama3_8b.sh|llama3:8b|Meta-Llama-3-8B|8 GB|Meta Llama 3|Text Generation"
    "install_05_llama3_70b.sh|llama3:70b|Meta-Llama-3-70B|48 GB|Meta Llama 3|Text Generation"
    "install_06_llama3.1_8b.sh|llama3.1:8b|Llama-3.1-8B-Instruct|8 GB|Meta Llama 3.1|Text Generation"
    "install_07_llama3.1_70b.sh|llama3.1:70b|Meta-Llama-3.1-70B-Instruct|48 GB|Meta Llama 3.1|Text Generation"
    "install_08_mistral_7b.sh|mistral:7b|Mistral-7B-Instruct-v0.1|8 GB|Mistral AI|Text Generation"
    "install_09_mixtral_8x7b.sh|mixtral:8x7b|Mixtral-8x7B-Instruct-v0.1|32 GB|Mistral AI|Text Generation"
    "install_10_mixtral_8x22b.sh|mixtral:8x22b|Mixtral-8x22B-Instruct-v0.1|80 GB|Mistral AI|Text Generation"
    "install_11_codellama_7b.sh|codellama:7b|CodeLlama-7b-hf|8 GB|Meta CodeLlama|Text Generation"
    "install_12_codellama_70b.sh|codellama:70b|CodeLlama-70b-hf|48 GB|Meta CodeLlama|Text Generation"
    "install_13_phind_codellama_34b.sh|phind-codellama:34b|Phind-CodeLlama-34B-v1|24 GB|Phind|Text Generation"
    "install_14_qwen_7b.sh|qwen:7b|Qwen1.5-7B-Chat|8 GB|Alibaba Qwen|Text Generation"
    "install_15_qwen_14b.sh|qwen:14b|Qwen1.5-14B-Chat|16 GB|Alibaba Qwen|Text Generation"
    "install_16_qwen_72b.sh|qwen:72b|Qwen1.5-72B-Chat|48 GB|Alibaba Qwen|Text Generation"
    "install_17_yi_6b.sh|yi:6b|Yi-1.5-6B|8 GB|01.AI Yi|Text Generation"
    "install_18_yi_34b.sh|yi:34b|Yi-1.5-34B-Chat|24 GB|01.AI Yi|Text Generation"
    "install_19_deepseek_7b.sh|deepseek-llm:7b|deepseek-llm-7b-chat|8 GB|DeepSeek|Text Generation"
    "install_20_deepseek_67b.sh|deepseek-llm:67b|deepseek-llm-67b-chat|48 GB|DeepSeek|Text Generation"
    "install_21_deepseek_moe_16b.sh|deepseek-v2:16b|deepseek-moe-16b-chat|16 GB|DeepSeek MoE|Text Generation"
    "install_22_whisper_large.sh|N/A|whisper-large-v2|8 GB|OpenAI Whisper|Speech Recognition"

    # ── NEW: Llama 3.x / 4.x Series ─────────────────────────────────────────
    "install_23_llama3.1_8b_instruct.sh|llama3.1:8b|Meta-Llama-3.1-8B-Instruct|8 GB|Meta Llama 3.1|Text Generation"
    "install_24_llama3.1_70b_instruct.sh|llama3.1:70b|Meta-Llama-3.1-70B-Instruct|48 GB|Meta Llama 3.1|Text Generation"
    "install_25_llama3.1_70b_taiwan.sh|llama3.1:70b|Llama-3.1-70B-Taiwan-Instruct|48 GB|Meta Llama 3.1|Text Generation"
    "install_26_llama3.1_405b.sh|llama3.1:405b|Meta-Llama-3.1-405B|240 GB|Meta Llama 3.1|Text Generation"
    "install_27_llama3.2_1b_instruct.sh|llama3.2:1b|Llama-3.2-1B-Instruct|2 GB|Meta Llama 3.2|Text Generation"
    "install_28_llama3.2_3b_instruct.sh|llama3.2:3b|Llama-3.2-3B-Instruct|4 GB|Meta Llama 3.2|Text Generation"
    "install_29_llama3.3_70b_instruct.sh|llama3.3:70b|Llama-3.3-70B-Instruct|48 GB|Meta Llama 3.3|Text Generation"
    "install_30_llama4_scout_17b.sh|llama4:scout|Llama-4-Scout-17B-16E-Instruct|24 GB|Meta Llama 4|Text Generation"

    # ── NEW: Qwen 2.5 Text Series ────────────────────────────────────────────
    "install_31_qwen2.5_0.5b.sh|qwen2.5:0.5b|Qwen2.5-0.5B-Instruct|1 GB|Alibaba Qwen 2.5|Text Generation"
    "install_32_qwen2.5_1.5b.sh|qwen2.5:1.5b|Qwen2.5-1.5B-Instruct|2 GB|Alibaba Qwen 2.5|Text Generation"
    "install_33_qwen2.5_3b.sh|qwen2.5:3b|Qwen2.5-3B-Instruct|4 GB|Alibaba Qwen 2.5|Text Generation"
    "install_34_qwen2.5_7b.sh|qwen2.5:7b|Qwen2.5-7B-Instruct|8 GB|Alibaba Qwen 2.5|Text Generation"
    "install_35_qwen2.5_14b.sh|qwen2.5:14b|Qwen2.5-14B-Instruct|16 GB|Alibaba Qwen 2.5|Text Generation"
    "install_36_qwen2.5_32b.sh|qwen2.5:32b|Qwen2.5-32B-Instruct|24 GB|Alibaba Qwen 2.5|Text Generation"
    "install_37_qwen2.5_72b.sh|qwen2.5:72b|Qwen2.5-72B-Instruct|48 GB|Alibaba Qwen 2.5|Text Generation"

    # ── NEW: Qwen 2.5 Vision (VL) Series ─────────────────────────────────────
    "install_38_qwen2.5vl_3b.sh|qwen2.5vl:3b|Qwen2.5-VL-3B-Instruct|4 GB|Alibaba Qwen 2.5 VL|Vision-Language"
    "install_39_qwen2.5vl_7b.sh|qwen2.5vl:7b|Qwen2.5-VL-7B-Instruct|8 GB|Alibaba Qwen 2.5 VL|Vision-Language"
    "install_40_qwen2.5vl_32b.sh|qwen2.5vl:32b|Qwen2.5-VL-32B-Instruct|24 GB|Alibaba Qwen 2.5 VL|Vision-Language"
    "install_41_qwen2.5vl_72b.sh|qwen2.5vl:72b|Qwen2.5-VL-72B-Instruct|48 GB|Alibaba Qwen 2.5 VL|Vision-Language"

    # ── NEW: Qwen 3 Series ───────────────────────────────────────────────────
    "install_42_qwen3_0.6b.sh|qwen3:0.6b|Qwen3-0.6B|1 GB|Alibaba Qwen 3|Text Generation"
    "install_43_qwen3_1.7b.sh|qwen3:1.7b|Qwen3-1.7B|2 GB|Alibaba Qwen 3|Text Generation"
    "install_44_qwen3_4b.sh|qwen3:4b|Qwen3-4B|4 GB|Alibaba Qwen 3|Text Generation"
    "install_45_qwen3_14b.sh|qwen3:14b|Qwen3-14B|16 GB|Alibaba Qwen 3|Text Generation"
    "install_46_qwen3_qwq_32b.sh|qwq:32b|Qwen3-QwQ-32B|24 GB|Alibaba Qwen 3 QwQ|Reasoning"

    # ── NEW: DeepSeek R1 Distill Series ──────────────────────────────────────
    "install_47_deepseek_r1_qwen_1.5b.sh|deepseek-r1:1.5b|DeepSeek-R1-Distill-Qwen-1.5B|2 GB|DeepSeek R1|Reasoning"
    "install_48_deepseek_r1_qwen_7b.sh|deepseek-r1:7b|DeepSeek-R1-Distill-Qwen-7B|8 GB|DeepSeek R1|Reasoning"
    "install_49_deepseek_r1_qwen_32b.sh|deepseek-r1:32b|DeepSeek-R1-Distill-Qwen-32B|24 GB|DeepSeek R1|Reasoning"
    "install_50_deepseek_r1_llama_70b.sh|deepseek-r1:70b|DeepSeek-R1-Distill-Llama-70B|48 GB|DeepSeek R1|Reasoning"

    # ── NEW: Gemma 3 Series ──────────────────────────────────────────────────
    "install_51_gemma3_270m.sh|gemma3:270m|Gemma-3-270M-IT|1 GB|Google Gemma 3|Text Generation"
    "install_52_gemma3_1b.sh|gemma3:1b|Gemma-3-1B-IT|2 GB|Google Gemma 3|Text Generation"
    "install_53_gemma3_4b.sh|gemma3:4b|Gemma-3-4B-IT|4 GB|Google Gemma 3|Text Generation"
    "install_54_gemma3_12b.sh|gemma3:12b|Gemma-3-12B-IT|12 GB|Google Gemma 3|Text Generation"
    "install_55_gemma3_27b.sh|gemma3:27b|Gemma-3-27B-IT|20 GB|Google Gemma 3|Text Generation"

    # ── NEW: InternVL3 Series (Community: blaifa/InternVL3) ───────────────────
    "install_56_internvl3_1b.sh|blaifa/InternVL3:1b|InternVL3-1B|2 GB|OpenGVLab InternVL3|Vision-Language"
    "install_57_internvl3_2b.sh|blaifa/InternVL3:2b|InternVL3-2B|4 GB|OpenGVLab InternVL3|Vision-Language"
    "install_58_internvl3_8b.sh|blaifa/InternVL3:8b|InternVL3-8B|8 GB|OpenGVLab InternVL3|Vision-Language"
    "install_59_internvl3_14b.sh|blaifa/InternVL3:14b|InternVL3-14B|16 GB|OpenGVLab InternVL3|Vision-Language"
    "install_60_internvl3_38b.sh|blaifa/InternVL3:38b|InternVL3-38B|24 GB|OpenGVLab InternVL3|Vision-Language"

    # ── NEW: Phi-4 Series ────────────────────────────────────────────────────
    "install_61_phi4_mini.sh|phi4-mini:latest|Phi-4-Mini-Instruct|4 GB|Microsoft Phi-4|Text Generation"
    "install_62_phi4_14b.sh|phi4:latest|Phi-4-14B|8 GB|Microsoft Phi-4|Text Generation"

    # ── NEW: Mistral Small 3.1 ───────────────────────────────────────────────
    "install_63_mistral_small_3.1_24b.sh|mistral-small:24b|Mistral-Small-3.1-24B-Instruct|16 GB|Mistral AI|Text Generation"

    # ── NEW: GPT-OSS Models ──────────────────────────────────────────────────
    "install_64_gpt_oss_20b.sh|N/A|GPT-OSS-20B|16 GB|GPT OSS|Text Generation"
    "install_65_gpt_oss_120b.sh|N/A|GPT-OSS-120B|80 GB|GPT OSS|Text Generation"
)

echo "Generating ${#MODELS[@]} model installer scripts..."
echo ""

for entry in "${MODELS[@]}"; do
    IFS='|' read -r FILENAME OLLAMA_TAG DISPLAY_NAME MIN_VRAM FAMILY TASK <<< "$entry"
    FILEPATH="${SCRIPT_DIR}/${FILENAME}"

    # Special case for non-Ollama models (Whisper, GPT-OSS)
    if [ "$OLLAMA_TAG" = "N/A" ]; then
        # Check if it's a GPT-OSS model
        if [[ "$FAMILY" == "GPT OSS" ]]; then
            cat > "$FILEPATH" <<GPT_EOF
#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  ${DISPLAY_NAME}
# Family: ${FAMILY}
# Task:   ${TASK}
# VRAM:   ${MIN_VRAM} minimum
#
# NOTE: GPT-OSS models are not available via Ollama.
# This script sets up the environment and placeholder for custom deployment.
# Integration requires a dedicated inference server (e.g., vLLM, TGI).
# ==============================================================================

set -e

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "\${SCRIPT_DIR}/_base_setup.sh"

print_header "aiDaptiv Benchmark — GPT-OSS Installer"
echo -e "Model: \${BOLD}${DISPLAY_NAME}\${NC}"
echo -e "Task:  ${TASK}"
echo ""

install_system_deps
validate_gpu
install_ollama
install_benchmark_tools
install_agent
configure_firewall

SERVER_IP=\$(hostname -I | awk '{print \$1}')

echo ""
print_header "Setup Complete!"
echo -e "\${BOLD}Model:\${NC}     ${DISPLAY_NAME}"
echo -e "\${BOLD}Family:\${NC}    ${FAMILY}"
echo -e "\${BOLD}Task:\${NC}      ${TASK}"
echo -e "\${BOLD}Min VRAM:\${NC}  ${MIN_VRAM}"
echo ""
echo -e "\${BOLD}NOTE:\${NC} ${DISPLAY_NAME} requires a custom inference server."
echo "      Deploy via vLLM or HuggingFace TGI with the appropriate model weights."
echo ""
echo -e "\${BOLD}Port Mapping:\${NC}"
echo "  ┌────────────────────────┬───────┐"
echo "  │ Service                │ Port  │"
echo "  ├────────────────────────┼───────┤"
echo "  │ Ollama API             │ 11434 │"
echo "  │ Benchmark Agent        │ 9100  │"
echo "  └────────────────────────┴───────┘"
echo ""
GPT_EOF
            chmod +x "$FILEPATH"
            echo "  ✓ ${FILENAME} (${DISPLAY_NAME}) — Special: Custom deployment"
            continue
        fi

        # Whisper special case
        cat > "$FILEPATH" <<WHISPER_EOF
#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer #22
# Model:  ${DISPLAY_NAME}
# Family: ${FAMILY}
# Task:   ${TASK}
# VRAM:   ${MIN_VRAM} minimum
#
# NOTE: Whisper is a speech recognition model and cannot be served via Ollama.
# This script installs Whisper via Python (openai-whisper) for local inference.
# Benchmark integration requires a custom adapter (not Ollama API).
# ==============================================================================

set -e

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "\${SCRIPT_DIR}/_base_setup.sh"

print_header "aiDaptiv Benchmark — Whisper Installer"
echo -e "Model: \${BOLD}${DISPLAY_NAME}\${NC}"
echo -e "Task:  ${TASK}"
echo ""

install_system_deps
validate_gpu
install_ollama
install_benchmark_tools
install_agent
configure_firewall

# ── Install Whisper ───────────────────────────────────────────────────────
print_header "7. Installing Whisper (Python)"
pip3 install --quiet --upgrade openai-whisper 2>/dev/null || \\
    pip3 install --quiet --user --upgrade openai-whisper
print_success "openai-whisper installed"

# Download the large-v2 model
print_status "Pre-downloading whisper-large-v2 weights..."
python3 -c "import whisper; whisper.load_model('large-v2')" 2>/dev/null && \\
    print_success "Whisper large-v2 model cached" || \\
    print_warning "Failed to pre-download. Model will download on first use."

SERVER_IP=\$(hostname -I | awk '{print \$1}')

echo ""
print_header "Setup Complete!"
echo -e "\${BOLD}Model:\${NC}     ${DISPLAY_NAME}"
echo -e "\${BOLD}Family:\${NC}    ${FAMILY}"
echo -e "\${BOLD}Task:\${NC}      ${TASK}"
echo -e "\${BOLD}Min VRAM:\${NC}  ${MIN_VRAM}"
echo ""
echo -e "\${BOLD}NOTE:\${NC} Whisper uses a custom Python inference pipeline."
echo "      It is NOT served via Ollama API."
echo "      Use: python3 -c \"import whisper; m=whisper.load_model('large-v2'); print(m.transcribe('audio.wav'))\""
echo ""
echo -e "\${BOLD}Port Mapping:\${NC}"
echo "  ┌────────────────────────┬───────┐"
echo "  │ Service                │ Port  │"
echo "  ├────────────────────────┼───────┤"
echo "  │ Ollama API             │ 11434 │"
echo "  │ Benchmark Agent        │ 9100  │"
echo "  └────────────────────────┴───────┘"
echo ""
WHISPER_EOF
        chmod +x "$FILEPATH"
        echo "  ✓ ${FILENAME} (${DISPLAY_NAME}) — Special: Python-based"
        continue
    fi

    # ── Standard Ollama-based models ──────────────────────────────────────
    DET_TAG=$(echo "$OLLAMA_TAG" | sed 's/:/-deterministic:/')

    cat > "$FILEPATH" <<MODEL_EOF
#!/bin/bash
# ==============================================================================
# aiDaptiv Benchmark — Model Installer
# Model:  ${DISPLAY_NAME}
# Ollama: ${OLLAMA_TAG}
# Family: ${FAMILY}
# Task:   ${TASK}
# VRAM:   ${MIN_VRAM} minimum
#
# Installs: Ollama, Benchmark Agent, oha, litellm, locust, llmperf
# Ports:    11434 (Ollama), 9100 (Agent)
# ==============================================================================

set -e

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "\${SCRIPT_DIR}/_base_setup.sh"

run_full_install \\
    "${OLLAMA_TAG}" \\
    "${DISPLAY_NAME}" \\
    "${MIN_VRAM}" \\
    "${FAMILY}" \\
    "${TASK}" \\
    "${DET_TAG}"
MODEL_EOF

    chmod +x "$FILEPATH"
    echo "  ✓ ${FILENAME} (${DISPLAY_NAME})"
done

# Make base script executable too
chmod +x "${SCRIPT_DIR}/_base_setup.sh"

echo ""
echo "Done! Generated ${#MODELS[@]} installer scripts in ${SCRIPT_DIR}/"
echo ""
echo "Usage: Copy the VM_Install folder to your target server, then run:"
echo "  bash install_XX_model_name.sh"
echo ""
