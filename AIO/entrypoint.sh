#!/bin/bash
# ============================================================================
#  aiDaptive Benchmark Suite - Docker Entrypoint
#  Tự động sửa benchmark.yaml để trỏ postgres host về container name
#  KHÔNG sửa source code gốc
# ============================================================================

set -e

CONFIG_FILE="/app/benchmark.yaml"

# Đổi postgres host từ localhost sang container name "postgres"
if [ -f "$CONFIG_FILE" ]; then
    sed -i 's/host: "localhost"/host: "postgres"/' "$CONFIG_FILE"
    sed -i "s/host: 'localhost'/host: 'postgres'/" "$CONFIG_FILE"
    echo "[AIO Entrypoint] Updated postgres host → postgres (container)"
fi

# Chạy app
exec python -m src "$@"
