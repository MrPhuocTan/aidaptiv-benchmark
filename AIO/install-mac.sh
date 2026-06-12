#!/bin/bash
# ============================================================================
#  aiDaptive Benchmark Suite - All In One Installer (macOS)
#
#  Script này sẽ:
#    1. Kiểm tra và cài Docker Desktop nếu chưa có
#    2. Khởi động Docker daemon nếu chưa chạy
#    3. Build Docker image cho ứng dụng
#    4. Chạy docker-compose (app + PostgreSQL)
#    5. Hiển thị thông tin truy cập
#
#  Cách dùng:
#    chmod +x install-mac.sh
#    ./install-mac.sh
# ============================================================================

set -euo pipefail

# ---- Colors & Helpers ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

info()    { echo -e "${WHITE}[INFO]    $1${NC}"; }
ok()      { echo -e "${GREEN}[✓ OK]    $1${NC}"; }
warn()    { echo -e "${YELLOW}[⚠ WARN]  $1${NC}"; }
err()     { echo -e "${RED}[✗ ERROR] $1${NC}"; }
step()    { echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${WHITE}${BOLD}  $1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
divider() { echo -e "${GRAY}──────────────────────────────────────────────────${NC}"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---- Lấy đường dẫn project root (parent của AIO) ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ============================================================================
#  Banner
# ============================================================================
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${WHITE}${BOLD}aiDaptive Benchmark Suite - AIO Installer (macOS)${NC}     ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${GRAY}All In One • Docker • Auto Setup${NC}                       ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
#  Step 1: Kiểm tra Docker
# ============================================================================
step "Step 1/5 — Kiểm tra Docker Desktop"

install_docker_mac() {
    echo ""
    info "Docker chưa được cài đặt trên máy này."
    divider

    if has_cmd brew; then
        info "Tìm thấy Homebrew. Cài Docker Desktop qua Homebrew..."
        echo ""
        echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  ⚠  CÀI ĐẶT DOCKER DESKTOP                         ║${NC}"
        echo -e "${YELLOW}║                                                       ║${NC}"
        echo -e "${YELLOW}║  macOS có thể yêu cầu mật khẩu admin để cài đặt.    ║${NC}"
        echo -e "${YELLOW}║  Vui lòng nhập mật khẩu khi được hỏi.               ║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""

        brew install --cask docker

        if [ $? -eq 0 ]; then
            ok "Docker Desktop đã cài thành công qua Homebrew."
        else
            err "Cài Docker qua Homebrew thất bại."
            info "Vui lòng tải Docker Desktop thủ công từ:"
            info "  https://www.docker.com/products/docker-desktop/"
            exit 1
        fi
    else
        echo ""
        echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║  ⚠  HOMEBREW KHÔNG TÌM THẤY                         ║${NC}"
        echo -e "${YELLOW}║                                                       ║${NC}"
        echo -e "${YELLOW}║  Bạn có muốn cài Homebrew trước không?               ║${NC}"
        echo -e "${YELLOW}║  (Homebrew cần quyền admin - sẽ yêu cầu mật khẩu)   ║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
        echo ""

        read -p "  Cài Homebrew và Docker? (y/n): " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Đang cài Homebrew... (có thể yêu cầu mật khẩu admin)"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Thêm Homebrew vào PATH cho cả Intel và Apple Silicon
            if [[ -f /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi

            info "Đang cài Docker Desktop..."
            brew install --cask docker
            ok "Docker Desktop đã cài thành công."
        else
            err "Docker Desktop là bắt buộc để chạy AIO."
            info "Vui lòng cài Docker Desktop thủ công:"
            info "  https://www.docker.com/products/docker-desktop/"
            exit 1
        fi
    fi
}

if has_cmd docker; then
    ok "Docker đã được cài: $(docker --version 2>&1)"
else
    install_docker_mac
fi

# ============================================================================
#  Step 2: Kiểm tra Docker daemon đang chạy
# ============================================================================
step "Step 2/5 — Kiểm tra Docker daemon"

wait_for_docker() {
    local max_wait=300
    local waited=0

    info "Đang đợi Docker daemon khởi động..."
    echo -e "${GRAY}  (Tối đa ${max_wait}s)${NC}"

    while ! docker info >/dev/null 2>&1; do
        if [ $waited -ge $max_wait ]; then
            echo ""
            warn "Docker daemon chưa sẵn sàng sau ${max_wait}s."
            echo ""
            echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
            echo -e "${YELLOW}║  Vui lòng kiểm tra Docker Desktop đã mở và sẵn      ║${NC}"
            echo -e "${YELLOW}║  sàng chưa, sau đó nhấn Enter để thử lại.           ║${NC}"
            echo -e "${YELLOW}║  Hoặc nhấn Ctrl+C để thoát.                         ║${NC}"
            echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
            echo ""
            read -p "  Nhấn Enter để thử lại..."
            waited=0
            continue
        fi
        sleep 2
        waited=$((waited + 2))
        printf "\r  ${GRAY}Đang đợi... ${waited}s${NC}  "
    done
    echo ""
    ok "Docker daemon đang chạy."
}

if docker info >/dev/null 2>&1; then
    ok "Docker daemon đang chạy."
else
    warn "Docker daemon chưa khởi động."
    info "Đang mở Docker Desktop..."

    open -a Docker 2>/dev/null || open /Applications/Docker.app 2>/dev/null || true

    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⏳ ĐANG CHỜ DOCKER KHỞI ĐỘNG                       ║${NC}"
    echo -e "${YELLOW}║                                                       ║${NC}"
    echo -e "${YELLOW}║  Docker Desktop đang khởi động.                      ║${NC}"
    echo -e "${YELLOW}║                                                       ║${NC}"
    echo -e "${YELLOW}║  ⚠  NẾU LÀ LẦN ĐẦU CÀI DOCKER:                    ║${NC}"
    echo -e "${YELLOW}║  1. Chuyển sang cửa sổ Docker Desktop                ║${NC}"
    echo -e "${YELLOW}║  2. Chấp nhận License Agreement (Accept)             ║${NC}"
    echo -e "${YELLOW}║  3. Bỏ qua survey / đăng nhập nếu được hỏi (Skip)   ║${NC}"
    echo -e "${YELLOW}║  4. Đợi Docker Desktop hiện 'Engine running'         ║${NC}"
    echo -e "${YELLOW}║  5. macOS có thể hỏi quyền mạng → bấm 'Allow'      ║${NC}"
    echo -e "${YELLOW}║                                                       ║${NC}"
    echo -e "${YELLOW}║  Script sẽ tự detect khi Docker sẵn sàng.           ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    wait_for_docker
fi

# Kiểm tra Docker Compose
if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose: $(docker compose version 2>&1)"
elif has_cmd docker-compose; then
    ok "docker-compose (legacy) đã cài."
    # Alias để dùng trong script
    shopt -s expand_aliases
    alias docker\ compose='docker-compose'
else
    err "Docker Compose không tìm thấy."
    info "Docker Desktop mới nhất đã tích hợp Docker Compose."
    info "Vui lòng cập nhật Docker Desktop."
    exit 1
fi

# ============================================================================
#  Step 3: Chuẩn bị môi trường
# ============================================================================
step "Step 3/5 — Chuẩn bị môi trường"

# Copy .env nếu chưa có
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    ok "Đã tạo file .env từ .env.example"
    info "Bạn có thể chỉnh sửa: $SCRIPT_DIR/.env"
else
    ok "File .env đã tồn tại."
fi

# Copy .dockerignore vào project root nếu chưa có
if [ ! -f "$PROJECT_ROOT/.dockerignore" ]; then
    cp "$SCRIPT_DIR/.dockerignore" "$PROJECT_ROOT/.dockerignore"
    ok "Đã copy .dockerignore vào project root"
fi

divider
info "Project root : $PROJECT_ROOT"
info "AIO dir      : $SCRIPT_DIR"
info "Compose file : $SCRIPT_DIR/docker-compose.yaml"

# ============================================================================
#  Step 4: Build Docker Image & Khởi động
# ============================================================================
step "Step 4/5 — Build Docker Image & Khởi động services"

echo ""
info "Đang build Docker image và khởi động containers..."
info "Lần đầu có thể mất 3-5 phút để tải image và cài dependencies."
echo ""

cd "$PROJECT_ROOT"

# Kiểm tra container cũ
if docker ps -a --format '{{.Names}}' | grep -q "aidaptive-app"; then
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠  CONTAINERS CŨ ĐÃ TỒN TẠI                       ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "  Rebuild và khởi động lại? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Dừng containers cũ..."
        docker compose -f "$SCRIPT_DIR/docker-compose.yaml" down 2>/dev/null || true
        info "Rebuild..."
        docker compose -f "$SCRIPT_DIR/docker-compose.yaml" up --build -d
    else
        info "Giữ nguyên containers hiện tại. Đảm bảo chúng đang chạy..."
        docker compose -f "$SCRIPT_DIR/docker-compose.yaml" up -d
    fi
else
    docker compose -f "$SCRIPT_DIR/docker-compose.yaml" up --build -d
fi

# ============================================================================
#  Step 5: Xác nhận & Hiển thị thông tin
# ============================================================================
step "Step 5/5 — Kiểm tra trạng thái"

# Đợi app khởi động
info "Đang đợi ứng dụng khởi động..."
APP_PORT=$(grep -oP 'AIDAPTIVE_APP_PORT=\K[0-9]+' "$SCRIPT_DIR/.env" 2>/dev/null || echo "8443")
MAX_WAIT=60
WAITED=0

while ! curl -sf "http://localhost:${APP_PORT}/" >/dev/null 2>&1; do
    if [ $WAITED -ge $MAX_WAIT ]; then
        warn "Ứng dụng chưa phản hồi sau ${MAX_WAIT}s. Kiểm tra logs:"
        info "  docker compose -f $SCRIPT_DIR/docker-compose.yaml logs app"
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    printf "\r  ${GRAY}Đang đợi... ${WAITED}s${NC}  "
done
echo ""

# Hiển thị trạng thái containers
divider
info "Trạng thái containers:"
docker compose -f "$SCRIPT_DIR/docker-compose.yaml" ps
divider

# ============================================================================
#  Kết quả
# ============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}${BOLD}✅ CÀI ĐẶT HOÀN TẤT!${NC}                                   ${GREEN}║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}🌐 Web UI:${NC}  ${CYAN}http://localhost:${APP_PORT}${NC}                   ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}🐘 PostgreSQL:${NC} ${CYAN}localhost:5432${NC}                          ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  ${GRAY}Lệnh hữu ích:${NC}                                         ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Xem logs:${NC}    ${GRAY}docker compose -f AIO/docker-compose.yaml logs -f${NC} ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Dừng:${NC}        ${GRAY}docker compose -f AIO/docker-compose.yaml down${NC}   ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Khởi động:${NC}   ${GRAY}docker compose -f AIO/docker-compose.yaml up -d${NC}  ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${WHITE}Rebuild:${NC}     ${GRAY}docker compose -f AIO/docker-compose.yaml up --build -d${NC} ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                          ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
