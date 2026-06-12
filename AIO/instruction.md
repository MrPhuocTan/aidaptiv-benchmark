# 📋 Hướng dẫn sử dụng AIO (All In One) Installer

> Tài liệu này hướng dẫn chi tiết từng bước cài đặt aiDaptive Benchmark Suite trên máy mới **từ con số 0** — không cần cài sẵn bất kỳ phần mềm nào ngoài hệ điều hành.

---

## 📦 AIO bao gồm gì?

AIO đóng gói toàn bộ hệ thống vào Docker:

| Thành phần | Mô tả |
|------------|--------|
| **App** (`aidaptive-benchmark`) | Ứng dụng Python (FastAPI + Uvicorn) — benchmark AI servers |
| **PostgreSQL** (`postgres:16-alpine`) | Database lưu trữ kết quả benchmark |

Chỉ cần **1 lệnh duy nhất**, script sẽ tự:
- Kiểm tra Docker → cài nếu chưa có (hỏi mật khẩu admin)
- Khởi động Docker daemon
- Build Docker image từ source code
- Chạy toàn bộ hệ thống qua Docker Compose

---

## 🍎 macOS

### Yêu cầu
- macOS 12 (Monterey) trở lên
- Quyền admin (để cài Docker Desktop)
- Internet (lần đầu)

### Các bước

```bash
# 1. Mở Terminal

# 2. Di chuyển vào thư mục project
cd /đường/dẫn/tới/aidaptive-benchmark

# 3. Cấp quyền chạy script
chmod +x AIO/install-mac.sh

# 4. Chạy installer
./AIO/install-mac.sh
```

### Quá trình cài đặt sẽ diễn ra như sau:

```
Step 1/5 — Kiểm tra Docker Desktop
├── Docker đã có?     → Bỏ qua
├── Có Homebrew?      → brew install --cask docker (yêu cầu mật khẩu)
└── Không có Homebrew? → Hỏi cài Homebrew trước → rồi cài Docker

Step 2/5 — Kiểm tra Docker daemon
├── Daemon đang chạy? → Bỏ qua
└── Chưa chạy?        → Tự mở Docker Desktop → đợi daemon sẵn sàng (tối đa 120s)
                         ⚠ Lần đầu macOS có thể hỏi quyền truy cập mạng → bấm "Allow"

Step 3/5 — Chuẩn bị môi trường
└── Tạo file .env từ .env.example

Step 4/5 — Build Docker Image & Khởi động
├── Build image aidaptive-benchmark (lần đầu ~3-5 phút)
└── docker compose up (PostgreSQL + App)

Step 5/5 — Kiểm tra trạng thái
└── Đợi app phản hồi HTTP → hiển thị URL truy cập
```

### Khi nào cần nhập mật khẩu?

| Tình huống | Mật khẩu |
|------------|----------|
| Cài Homebrew | macOS system password (popup Terminal) |
| `brew install --cask docker` | macOS system password |
| Mở Docker Desktop lần đầu | macOS popup "Allow network access" → bấm Allow |

---

## 🐧 Linux

### Yêu cầu
- Ubuntu 20.04+ / Debian 11+ / CentOS 8+ / RHEL 8+ / Fedora 36+
- User có quyền sudo
- Internet (lần đầu)

### Các bước

```bash
# 1. Di chuyển vào thư mục project
cd /đường/dẫn/tới/aidaptive-benchmark

# 2. Cấp quyền chạy script
chmod +x AIO/install-linux.sh

# 3. Chạy installer
./AIO/install-linux.sh
```

### Khi nào cần nhập mật khẩu?

| Tình huống | Lệnh cần sudo |
|------------|----------------|
| Cài Docker Engine | `sudo apt-get install docker-ce` hoặc `sudo dnf install docker-ce` |
| Start Docker daemon | `sudo systemctl start docker` |
| Thêm user vào docker group | `sudo usermod -aG docker $USER` |
| Cài Docker Compose plugin | `sudo apt-get install docker-compose-plugin` |

> ⚠ Script sẽ hiện banner **"🔐 YÊU CẦU QUYỀN ADMIN (sudo)"** trước MỖI lệnh cần sudo để anh biết trước.

---

## 🪟 Windows

### Yêu cầu
- Windows 10 (build 19041+) hoặc Windows 11
- Quyền Administrator
- Internet (lần đầu)

### Các bước

```
Cách 1: Click chuột phải vào AIO\install-windows.bat → "Run as Administrator"

Cách 2:
  1. Mở CMD với quyền Admin (Start → gõ "cmd" → Run as Administrator)
  2. cd C:\đường\dẫn\tới\aidaptive-benchmark
  3. AIO\install-windows.bat
```

### Khi nào cần xác nhận?

| Tình huống | Popup |
|------------|-------|
| Cài Docker Desktop qua winget | UAC popup → bấm "Yes" |
| Mở Docker Desktop lần đầu | UAC popup → bấm "Yes" |
| Bật WSL2 (nếu chưa có) | Cần chạy `wsl --install` trong PowerShell Admin → **restart máy** |

> ⚠ Nếu máy chưa bật WSL2 hoặc Hyper-V, script sẽ cảnh báo và hướng dẫn. Sau khi bật cần **restart máy** rồi chạy lại script.

---

## 🌐 Sau khi cài xong

Truy cập ứng dụng:

```
🌐 Web UI:      http://localhost:8443
🐘 PostgreSQL:  localhost:5432 (user: aidaptive / pass: aidaptive2024)
```

---

## 🛠 Quản lý sau khi cài

### Xem logs

```bash
# Tất cả logs
docker compose -f AIO/docker-compose.yaml logs -f

# Chỉ app
docker compose -f AIO/docker-compose.yaml logs -f app

# Chỉ database
docker compose -f AIO/docker-compose.yaml logs -f postgres
```

### Dừng / Khởi động lại

```bash
# Dừng toàn bộ (giữ data)
docker compose -f AIO/docker-compose.yaml down

# Khởi động lại
docker compose -f AIO/docker-compose.yaml up -d

# Rebuild sau khi code thay đổi
docker compose -f AIO/docker-compose.yaml up --build -d

# Xóa toàn bộ (BAO GỒM DATA)
docker compose -f AIO/docker-compose.yaml down -v
```

### Đổi port

Chỉnh file `AIO/.env`:

```env
AIDAPTIVE_APP_PORT=9999
```

Rồi restart:

```bash
docker compose -f AIO/docker-compose.yaml down
docker compose -f AIO/docker-compose.yaml up -d
```

---

## ❓ FAQ & Xử lý lỗi

### Q: Máy tôi đã có Docker rồi, chạy script có sao không?
**A:** Không sao. Script kiểm tra trước — nếu Docker đã có thì bỏ qua bước cài, chỉ build và run.

### Q: Đã có containers cũ từ lần chạy trước?
**A:** Script sẽ hỏi "Rebuild và khởi động lại? (y/n)" — chọn `y` để rebuild hoặc `n` để giữ nguyên.

### Q: Port 8443 đã bị chiếm?
**A:** Đổi `AIDAPTIVE_APP_PORT` trong `AIO/.env` thành port khác (VD: 9443).

### Q: Build thất bại?
**A:** Kiểm tra logs: `docker compose -f AIO/docker-compose.yaml logs`. Nguyên nhân thường gặp:
- Mạng chậm/mất kết nối khi tải pip packages
- Hết dung lượng ổ cứng

### Q: App container restart liên tục?
**A:** Kiểm tra lỗi: `docker compose -f AIO/docker-compose.yaml logs app --tail 30`

### Q: Muốn xóa hoàn toàn để cài lại từ đầu?
```bash
docker compose -f AIO/docker-compose.yaml down -v --rmi all
rm -f AIO/.env
# Chạy lại script
./AIO/install-mac.sh
```

---

## 📁 Cấu trúc file

```
AIO/
├── install-mac.sh          # Installer macOS
├── install-linux.sh        # Installer Linux
├── install-windows.bat     # Installer Windows
├── Dockerfile              # Build image cho app
├── docker-compose.yaml     # Compose: app + PostgreSQL
├── entrypoint.sh           # Script khởi động trong container
├── .dockerignore           # Exclude files khỏi Docker build
├── .env.example            # Template biến môi trường
├── README.md               # Tóm tắt ngắn
└── instruction.md          # Hướng dẫn chi tiết (file này)
```

---

**Tác giả:** MrPhuocTan — Ted.trinh@tpisoftware.com — 097.201.2901
