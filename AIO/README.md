# 🚀 aiDaptive Benchmark Suite — AIO (All In One) Installer

Bộ cài đặt **một lệnh duy nhất** để triển khai toàn bộ hệ thống aiDaptive Benchmark trên bất kỳ máy mới nào.

---

## 📋 Yêu cầu hệ thống

| Thành phần | Yêu cầu |
|------------|----------|
| **RAM** | Tối thiểu 4GB (khuyến nghị 8GB+) |
| **Ổ cứng** | 5GB trống |
| **Mạng** | Internet (lần đầu để tải Docker images) |
| **OS** | macOS 12+, Windows 10/11, Ubuntu 20.04+, Debian 11+, CentOS 8+, RHEL 8+, Fedora 36+ |

> **Lưu ý:** Script sẽ tự động cài Docker nếu chưa có. Không cần cài thủ công bất cứ thứ gì.

---

## ⚡ Cài đặt nhanh

### 🍎 macOS

```bash
cd aidaptive-benchmark
chmod +x AIO/install-mac.sh
./AIO/install-mac.sh
```

### 🐧 Linux (Ubuntu/Debian/CentOS/RHEL/Fedora)

```bash
cd aidaptive-benchmark
chmod +x AIO/install-linux.sh
./AIO/install-linux.sh
```

### 🪟 Windows

```
Cách 1: Click chuột phải vào install-windows.bat → "Run as Administrator"
Cách 2: Mở CMD (Admin) → cd aidaptive-benchmark → AIO\install-windows.bat
```

---

## 📁 Cấu trúc thư mục

```
AIO/
├── install-mac.sh          # Installer cho macOS
├── install-linux.sh        # Installer cho Linux
├── install-windows.bat     # Installer cho Windows
├── Dockerfile              # Docker image cho ứng dụng Python
├── docker-compose.yaml     # Compose: app + PostgreSQL
├── .dockerignore           # Exclude files khỏi Docker build
├── .env.example            # File biến môi trường mẫu
├── .env                    # File biến môi trường (tạo tự động khi chạy)
└── README.md               # File này
```

---

## 🔧 Script làm gì?

Mỗi install script thực hiện **5 bước** tự động:

| Bước | Mô tả | Cần mật khẩu? |
|------|--------|---------------|
| **1** | Kiểm tra Docker, cài nếu chưa có | ✅ Có thể cần (admin/sudo) |
| **2** | Khởi động Docker daemon | ✅ Linux cần sudo |
| **3** | Chuẩn bị file `.env`, `.dockerignore` | ❌ Không |
| **4** | Build Docker image + chạy docker-compose | ❌ Không |
| **5** | Kiểm tra trạng thái, hiển thị URL truy cập | ❌ Không |

### Khi nào cần nhập mật khẩu?

- **macOS:** Khi cài Docker Desktop qua Homebrew (system password)
- **Linux:** Khi cài Docker Engine, start daemon (sudo password)
- **Windows:** UAC popup khi cài Docker Desktop (click "Yes")

---

## 🌐 Sau khi cài xong

Truy cập ứng dụng tại: **http://localhost:8443**

PostgreSQL: `localhost:5432` (user: `aidaptive`, password: `aidaptive2024`)

---

## 🛠 Lệnh hữu ích

```bash
# Xem logs real-time
docker compose -f AIO/docker-compose.yaml logs -f

# Xem logs chỉ app
docker compose -f AIO/docker-compose.yaml logs -f app

# Dừng toàn bộ
docker compose -f AIO/docker-compose.yaml down

# Khởi động lại
docker compose -f AIO/docker-compose.yaml up -d

# Rebuild sau khi sửa code
docker compose -f AIO/docker-compose.yaml up --build -d

# Xóa toàn bộ (bao gồm data)
docker compose -f AIO/docker-compose.yaml down -v
```

---

## ⚙️ Tùy chỉnh

Chỉnh sửa file `AIO/.env` để thay đổi cấu hình:

```env
# Port ứng dụng (mặc định: 8443)
AIDAPTIVE_APP_PORT=8443

# PostgreSQL credentials
POSTGRES_USER=aidaptive
POSTGRES_PASSWORD=aidaptive2024
POSTGRES_DB=aidaptive_benchmark
```

---

## ❓ Xử lý lỗi

| Lỗi | Giải pháp |
|-----|-----------|
| Docker daemon not running | Mở Docker Desktop thủ công |
| Port 8443 đã bị chiếm | Đổi `AIDAPTIVE_APP_PORT` trong `.env` |
| Permission denied (Linux) | Chạy lại script hoặc `sudo ./AIO/install-linux.sh` |
| WSL2 chưa bật (Windows) | PowerShell Admin: `wsl --install` → restart máy |
| Build thất bại | Kiểm tra `docker compose -f AIO/docker-compose.yaml logs` |
| Container không connect được DB | Đợi 30s cho postgres healthcheck pass |

---

## 📝 Tác giả

**MrPhuocTan** — Ted.trinh@tpisoftware.com — 097.201.2901
