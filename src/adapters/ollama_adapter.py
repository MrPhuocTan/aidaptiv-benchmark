"""Ollama Native API adapter - direct measurement from Ollama response"""

import time
import json
import logging
from src.time_utils import get_local_time
from typing import List, Tuple, Optional

import httpx

from src.adapters.base import BaseToolAdapter
from src.models import BenchmarkResult, PromptLogEntry, ToolEvidence


class OllamaAdapter(BaseToolAdapter):
    tool_name = "ollama_native"

    def __init__(self, ollama_url: str, model: str):
        self.ollama_url = ollama_url.rstrip("/")
        self.model = model

    def is_available(self) -> bool:
        """Always available — uses Ollama HTTP API directly."""
        return True

    async def run(self, prompts: list) -> Tuple[List[BenchmarkResult], List[PromptLogEntry], Optional[ToolEvidence]]:
        """Run benchmark by sending each prompt to Ollama API (non-streaming)."""
        results = []
        prompt_logs = []
        raw_outputs = []


        for i, item in enumerate(prompts):
            prompt_text = item.get("prompt", "")
            result, p_log, raw_resp = await self._single_request(prompt_text, i)
            if result:
                results.append(result)
            if p_log:
                prompt_logs.append(p_log)
            if raw_resp:
                raw_outputs.append(raw_resp)

        evidence = ToolEvidence(
            tool_name=self.tool_name,
            tool_version="native",
            command_line="API POST /api/generate",
            raw_output=json.dumps(raw_outputs, indent=2),
            output_format="json",
        ) if raw_outputs else None

        return results, prompt_logs, evidence

    async def _single_request(self, prompt: str, index: int) -> Tuple[BenchmarkResult, PromptLogEntry, dict]:
        """Send single request and measure metrics from Ollama response"""

        result = BenchmarkResult(
            timestamp=get_local_time(),
            tool=self.tool_name,
            model=self.model,
        )
        p_log = PromptLogEntry(
            prompt_index=index,
            prompt_text=prompt,
        )
        raw_data = {}

        try:
            wall_start = time.perf_counter()
            p_log.sent_at = get_local_time()

            async with httpx.AsyncClient(timeout=600.0) as client:

                resp = await client.post(
                    f"{self.ollama_url}/api/generate",
                    json={
                        "model": self.model,
                        "prompt": prompt,
                        "stream": False,
                    },
                )

            wall_end = time.perf_counter()
            p_log.completed_at = get_local_time()

            if resp.status_code != 200:
                p_log.status = "error"
                p_log.error_message = f"HTTP {resp.status_code}: {resp.text}"
                raise RuntimeError(f"Ollama API returned HTTP {resp.status_code}: {resp.text}")

            data = resp.json()
            raw_data = data


            # Extract Ollama native metrics (nanoseconds)
            total_duration = data.get("total_duration", 0)
            load_duration = data.get("load_duration", 0)
            prompt_eval_duration = data.get("prompt_eval_duration", 0)
            eval_duration = data.get("eval_duration", 0)
            prompt_eval_count = data.get("prompt_eval_count", 0)
            eval_count = data.get("eval_count", 0)

            # TTFT = time until first output token
            if prompt_eval_duration > 0:
                result.ttft_ms = (load_duration + prompt_eval_duration) / 1e6
            else:
                result.ttft_ms = (wall_end - wall_start) * 1000

            # TPOT = time per output token
            if eval_count > 0 and eval_duration > 0:
                result.tpot_ms = (eval_duration / 1e6) / eval_count

            # TPS = tokens per second
            if eval_count > 0 and eval_duration > 0:
                result.tps = eval_count / (eval_duration / 1e9)

            # Token counts
            result.prompt_tokens = prompt_eval_count
            result.completion_tokens = eval_count
            result.total_tokens = prompt_eval_count + eval_count

            # Success
            result.total_requests = 1
            result.successful_requests = 1
            result.failed_requests = 0
            result.error_rate = 0.0
            
            p_log.response_text = data.get("response", "")
            p_log.ttft_ms = result.ttft_ms
            p_log.tpot_ms = result.tpot_ms
            p_log.tps = result.tps
            p_log.tokens_generated = eval_count

        except Exception as e:
            p_log.status = "error"
            p_log.error_message = str(e)
            logging.getLogger(__name__).error("Ollama request failed: %s", e)

        return result, p_log, raw_data
