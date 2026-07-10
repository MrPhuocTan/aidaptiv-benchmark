# 📦 VM_Install — aiDaptiv Benchmark Model Installers

> One-command setup scripts for each Phison aiDAPTIV-supported model.
> Each script installs **all benchmark tools + monitoring agent + model** on an Ubuntu AI server.

---

## Quick Start

```bash
# 1. Copy this folder to your target VM
scp -r VM_Install/ user@server-ip:~/

# 2. SSH into the server
ssh user@server-ip

# 3. Run the installer for your desired model
cd ~/VM_Install
bash install_34_qwen2.5_7b.sh    # Example: Qwen2.5-7B
```

---

## What Each Script Installs

| Component | Description | Port |
|-----------|-------------|------|
| **Ollama** | LLM inference server | `11434` |
| **Benchmark Agent** | GPU/CPU/Disk/Network metrics collector (FastAPI) | `9100` |
| **oha** | HTTP load tester (Rust) | — |
| **litellm** | Universal LLM API proxy (Python) | — |
| **locust** | Distributed load testing (Python) | — |
| **llmperf** | Anyscale LLM benchmark tool (Python) | — |
| **Model** | Downloaded & configured via Ollama with deterministic variant | — |

---

## Available Installers (65 models)

### Legacy Models (#01 – #22)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 1 | `install_01_llama2_7b.sh` | Llama-2-7b-hf | Meta Llama 2 | 8 GB |
| 2 | `install_02_llama2_13b.sh` | Llama-2-13b-hf | Meta Llama 2 | 16 GB |
| 3 | `install_03_llama2_70b.sh` | Llama-2-70b-hf | Meta Llama 2 | 48 GB |
| 4 | `install_04_llama3_8b.sh` | Meta-Llama-3-8B | Meta Llama 3 | 8 GB |
| 5 | `install_05_llama3_70b.sh` | Meta-Llama-3-70B | Meta Llama 3 | 48 GB |
| 6 | `install_06_llama3.1_8b.sh` | Llama-3.1-8B-Instruct | Meta Llama 3.1 | 8 GB |
| 7 | `install_07_llama3.1_70b.sh` | Meta-Llama-3.1-70B-Instruct | Meta Llama 3.1 | 48 GB |
| 8 | `install_08_mistral_7b.sh` | Mistral-7B-Instruct-v0.1 | Mistral AI | 8 GB |
| 9 | `install_09_mixtral_8x7b.sh` | Mixtral-8x7B-Instruct-v0.1 | Mistral AI | 32 GB |
| 10 | `install_10_mixtral_8x22b.sh` | Mixtral-8x22B-Instruct-v0.1 | Mistral AI | 80 GB |
| 11 | `install_11_codellama_7b.sh` | CodeLlama-7b-hf | Meta CodeLlama | 8 GB |
| 12 | `install_12_codellama_70b.sh` | CodeLlama-70b-hf | Meta CodeLlama | 48 GB |
| 13 | `install_13_phind_codellama_34b.sh` | Phind-CodeLlama-34B-v1 | Phind | 24 GB |
| 14 | `install_14_qwen_7b.sh` | Qwen1.5-7B-Chat | Alibaba Qwen | 8 GB |
| 15 | `install_15_qwen_14b.sh` | Qwen1.5-14B-Chat | Alibaba Qwen | 16 GB |
| 16 | `install_16_qwen_72b.sh` | Qwen1.5-72B-Chat | Alibaba Qwen | 48 GB |
| 17 | `install_17_yi_6b.sh` | Yi-1.5-6B | 01.AI Yi | 8 GB |
| 18 | `install_18_yi_34b.sh` | Yi-1.5-34B-Chat | 01.AI Yi | 24 GB |
| 19 | `install_19_deepseek_7b.sh` | deepseek-llm-7b-chat | DeepSeek | 8 GB |
| 20 | `install_20_deepseek_67b.sh` | deepseek-llm-67b-chat | DeepSeek | 48 GB |
| 21 | `install_21_deepseek_moe_16b.sh` | deepseek-moe-16b-chat | DeepSeek MoE | 16 GB |
| 22 | `install_22_whisper_large.sh` | whisper-large-v2 | OpenAI Whisper | 8 GB |

### Llama 3.x / 4.x Series (#23 – #30)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 23 | `install_23_llama3.1_8b_instruct.sh` | Meta-Llama-3.1-8B-Instruct | Meta Llama 3.1 | 8 GB |
| 24 | `install_24_llama3.1_70b_instruct.sh` | Meta-Llama-3.1-70B-Instruct | Meta Llama 3.1 | 48 GB |
| 25 | `install_25_llama3.1_70b_taiwan.sh` | Llama-3.1-70B-Taiwan-Instruct | Meta Llama 3.1 | 48 GB |
| 26 | `install_26_llama3.1_405b.sh` | Meta-Llama-3.1-405B | Meta Llama 3.1 | 240 GB |
| 27 | `install_27_llama3.2_1b_instruct.sh` | Llama-3.2-1B-Instruct | Meta Llama 3.2 | 2 GB |
| 28 | `install_28_llama3.2_3b_instruct.sh` | Llama-3.2-3B-Instruct | Meta Llama 3.2 | 4 GB |
| 29 | `install_29_llama3.3_70b_instruct.sh` | Llama-3.3-70B-Instruct | Meta Llama 3.3 | 48 GB |
| 30 | `install_30_llama4_scout_17b.sh` | Llama-4-Scout-17B-16E-Instruct | Meta Llama 4 | 24 GB |

### Qwen 2.5 Text Series (#31 – #37)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 31 | `install_31_qwen2.5_0.5b.sh` | Qwen2.5-0.5B-Instruct | Alibaba Qwen 2.5 | 1 GB |
| 32 | `install_32_qwen2.5_1.5b.sh` | Qwen2.5-1.5B-Instruct | Alibaba Qwen 2.5 | 2 GB |
| 33 | `install_33_qwen2.5_3b.sh` | Qwen2.5-3B-Instruct | Alibaba Qwen 2.5 | 4 GB |
| 34 | `install_34_qwen2.5_7b.sh` | Qwen2.5-7B-Instruct | Alibaba Qwen 2.5 | 8 GB |
| 35 | `install_35_qwen2.5_14b.sh` | Qwen2.5-14B-Instruct | Alibaba Qwen 2.5 | 16 GB |
| 36 | `install_36_qwen2.5_32b.sh` | Qwen2.5-32B-Instruct | Alibaba Qwen 2.5 | 24 GB |
| 37 | `install_37_qwen2.5_72b.sh` | Qwen2.5-72B-Instruct | Alibaba Qwen 2.5 | 48 GB |

### Qwen 2.5 Vision (VL) Series (#38 – #41)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 38 | `install_38_qwen2.5vl_3b.sh` | Qwen2.5-VL-3B-Instruct | Alibaba Qwen 2.5 VL | 4 GB |
| 39 | `install_39_qwen2.5vl_7b.sh` | Qwen2.5-VL-7B-Instruct | Alibaba Qwen 2.5 VL | 8 GB |
| 40 | `install_40_qwen2.5vl_32b.sh` | Qwen2.5-VL-32B-Instruct | Alibaba Qwen 2.5 VL | 24 GB |
| 41 | `install_41_qwen2.5vl_72b.sh` | Qwen2.5-VL-72B-Instruct | Alibaba Qwen 2.5 VL | 48 GB |

### Qwen 3 Series (#42 – #46)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 42 | `install_42_qwen3_0.6b.sh` | Qwen3-0.6B | Alibaba Qwen 3 | 1 GB |
| 43 | `install_43_qwen3_1.7b.sh` | Qwen3-1.7B | Alibaba Qwen 3 | 2 GB |
| 44 | `install_44_qwen3_4b.sh` | Qwen3-4B | Alibaba Qwen 3 | 4 GB |
| 45 | `install_45_qwen3_14b.sh` | Qwen3-14B | Alibaba Qwen 3 | 16 GB |
| 46 | `install_46_qwen3_qwq_32b.sh` | Qwen3-QwQ-32B | Alibaba Qwen 3 QwQ | 24 GB |

### DeepSeek R1 Distill Series (#47 – #50)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 47 | `install_47_deepseek_r1_qwen_1.5b.sh` | DeepSeek-R1-Distill-Qwen-1.5B | DeepSeek R1 | 2 GB |
| 48 | `install_48_deepseek_r1_qwen_4b.sh` | DeepSeek-R1-Distill-Qwen-4B | DeepSeek R1 | 4 GB |
| 49 | `install_49_deepseek_r1_qwen_32b.sh` | DeepSeek-R1-Distill-Qwen-32B | DeepSeek R1 | 24 GB |
| 50 | `install_50_deepseek_r1_llama_70b.sh` | DeepSeek-R1-Distill-Llama-70B | DeepSeek R1 | 48 GB |

### Google Gemma 3 Series (#51 – #55)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 51 | `install_51_gemma3_270m.sh` | Gemma-3-270M-IT | Google Gemma 3 | 1 GB |
| 52 | `install_52_gemma3_1b.sh` | Gemma-3-1B-IT | Google Gemma 3 | 2 GB |
| 53 | `install_53_gemma3_4b.sh` | Gemma-3-4B-IT | Google Gemma 3 | 4 GB |
| 54 | `install_54_gemma3_12b.sh` | Gemma-3-12B-IT | Google Gemma 3 | 12 GB |
| 55 | `install_55_gemma3_27b.sh` | Gemma-3-27B-IT | Google Gemma 3 | 20 GB |

### InternVL3 Vision Series (#56 – #60)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 56 | `install_56_internvl3_1b.sh` | InternVL3-1B | OpenGVLab InternVL3 | 2 GB |
| 57 | `install_57_internvl3_2b.sh` | InternVL3-2B | OpenGVLab InternVL3 | 4 GB |
| 58 | `install_58_internvl3_8b.sh` | InternVL3-8B | OpenGVLab InternVL3 | 8 GB |
| 59 | `install_59_internvl3_14b.sh` | InternVL3-14B | OpenGVLab InternVL3 | 16 GB |
| 60 | `install_60_internvl3_38b.sh` | InternVL3-38B | OpenGVLab InternVL3 | 24 GB |

### Phi-4 Series (#61 – #62)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 61 | `install_61_phi4_mini.sh` | Phi-4-Mini-Instruct | Microsoft Phi-4 | 4 GB |
| 62 | `install_62_phi4_multimodal.sh` | Phi-4-Multimodal-Instruct | Microsoft Phi-4 | 8 GB |

### Mistral Small 3.1 (#63)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 63 | `install_63_mistral_small_3.1_24b.sh` | Mistral-Small-3.1-24B-Instruct | Mistral AI | 16 GB |

### GPT-OSS Models (#64 – #65)

| # | Script | Model | Family | VRAM |
|---|--------|-------|--------|------|
| 64 | `install_64_gpt_oss_20b.sh` | GPT-OSS-20B | GPT OSS | 16 GB |
| 65 | `install_65_gpt_oss_120b.sh` | GPT-OSS-120B | GPT OSS | 80 GB |

---

## Port Mapping

```
┌──────────────────────────────────────────────────┐
│                  AI Server (VM)                  │
│                                                  │
│  ┌──────────────┐     ┌──────────────────────┐   │
│  │   Ollama     │     │  Benchmark Agent     │   │
│  │  :11434      │     │  :9100               │   │
│  │              │     │                      │   │
│  │  /api/generate     │  /health             │   │
│  │  /api/chat   │     │  /metrics/gpu        │   │
│  │  /api/tags   │     │  /metrics/system     │   │
│  │              │     │  /ollama/status       │   │
│  │              │     │  /info               │   │
│  └──────────────┘     └──────────────────────┘   │
│                                                  │
│  ┌──────────────────────────────────────────┐    │
│  │  Benchmark Tools (Client-side on VM)     │    │
│  │  oha, litellm, locust, llmperf          │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
           │                    │
           ▼                    ▼
    ┌──────────────────────────────────┐
    │  Benchmark Suite (Mac/Control)   │
    │  http://control-ip:8443          │
    │                                  │
    │  Connects to:                    │
    │    ollama_url → :11434           │
    │    agent_url  → :9100            │
    └──────────────────────────────────┘
```

---

## After Installation

After running an installer, add the server to your `benchmark.yaml`:

```yaml
servers:
  server_new:
    name: "VM — Qwen2.5-7B"
    ollama_url: "http://<SERVER_IP>:11434"
    agent_url: "http://<SERVER_IP>:9100"

models:
  - "qwen2.5:7b"
```

---

## Deterministic Models

Each installer automatically creates a **deterministic variant** with fixed parameters for reproducible benchmarks:

| Parameter | Value |
|-----------|-------|
| `temperature` | 0 |
| `top_p` | 1.0 |
| `top_k` | 1 |
| `seed` | 42 |
| `num_predict` | 512 |

The deterministic model tag follows the pattern: `<model>-deterministic:<size>`

---

## Prerequisites

- **OS**: Ubuntu 22.04+ (recommended: Ubuntu 24.04 LTS)
- **GPU**: NVIDIA GPU with appropriate VRAM (see tables above)
- **Driver**: NVIDIA Driver 535+ installed
- **Network**: Internet access for package downloads
- **Permissions**: `sudo` access required

---

## File Structure

```
VM_Install/
├── README.md                              # This file
├── _base_setup.sh                         # Shared installation library
├── generate_all_installers.sh             # Generator script (run once)
├── install_01_llama2_7b.sh                # Legacy model installers
├── ...
├── install_22_whisper_large.sh
├── install_23_llama3.1_8b_instruct.sh     # New model installers
├── ...
└── install_65_gpt_oss_120b.sh
```
