# ============================================================================
#  aiDaptiv Benchmark Suite - Dockerfile
#  Build: docker build -f AIO/Dockerfile -t aidaptiv-benchmark .
#  (Chạy từ thư mục gốc project)
#
#  KHÔNG sửa source code gốc - dùng entrypoint để config runtime
# ============================================================================

FROM python:3.11-slim AS base

# Metadata
LABEL maintainer="MrPhuocTan <Ted.trinh@tpisoftware.com>"
LABEL description="aiDaptiv Benchmark Suite - All In One"
LABEL version="1.0.0"

# Tránh Python buffer output
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Thư mục làm việc trong container
WORKDIR /app

# ---- Giai đoạn 1: Cài dependencies ----
FROM base AS dependencies

# Cài system packages cần thiết cho psycopg2, aiohttp, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    git \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements trước (tận dụng Docker cache)
COPY requirements.txt .

# llmperf yêu cầu Python <3.11, skip nó (optional tool - app xử lý gracefully)
RUN pip install --no-cache-dir --upgrade pip \
    && grep -v "llmperf" requirements.txt > requirements_docker.txt \
    && pip install --no-cache-dir -r requirements_docker.txt \
    && rm requirements_docker.txt

# ---- Giai đoạn 2: App final ----
FROM base AS final

# Cài runtime libraries + TeX Live cho PDF reports
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    sed \
    # TeX Live cho xuất PDF báo cáo chất lượng cao (xelatex)
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    texlive-lang-cjk \
    texlive-lang-chinese \
    lmodern \
    && rm -rf /var/lib/apt/lists/*

# Copy installed packages từ dependencies stage
COPY --from=dependencies /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=dependencies /usr/local/bin /usr/local/bin

# Copy source code (KHÔNG sửa đổi gì - giữ nguyên bản gốc)
COPY src/ ./src/
COPY templates/ ./templates/
COPY static/ ./static/
COPY benchmark.yaml .
COPY requirements.txt .

# Tạo entrypoint inline - sửa benchmark.yaml lúc runtime để trỏ postgres → container
RUN printf '#!/bin/bash\nset -e\n\
CONFIG_FILE="/app/benchmark.yaml"\n\
if [ -f "$CONFIG_FILE" ]; then\n\
  sed -i '\''s/host: "localhost"/host: "postgres"/'\'' "$CONFIG_FILE"\n\
  sed -i "s/host: '\''localhost'\''/host: '\''postgres'\''/" "$CONFIG_FILE"\n\
  echo "[AIO] Updated postgres host -> postgres (container)"\n\
fi\n\
exec python -m src "$@"\n' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Expose port
EXPOSE 8443

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8443/ || exit 1

# Dùng entrypoint để sửa config lúc runtime, không đụng source
ENTRYPOINT ["/app/entrypoint.sh"]
