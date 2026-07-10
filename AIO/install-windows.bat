@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

REM ============================================================================
REM  aiDaptiv Benchmark Suite - All In One Installer (Windows)
REM
REM  Script nay se:
REM    1. Kiem tra va cai Docker Desktop neu chua co
REM    2. Khoi dong Docker Desktop
REM    3. Build Docker image cho ung dung
REM    4. Chay docker-compose (app + PostgreSQL)
REM    5. Hien thi thong tin truy cap
REM
REM  Cach dung:
REM    Click chuot phai -> Run as Administrator
REM    Hoac: cmd /c install-windows.bat
REM ============================================================================

REM ---- Colors (Windows 10+ ANSI support) ----
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "CYAN=[96m"
set "PURPLE=[95m"
set "WHITE=[97m"
set "GRAY=[90m"
set "NC=[0m"
set "BOLD=[1m"

REM ---- Lay duong dan script ----
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM ---- Project root (parent cua AIO) ----
for %%I in ("%SCRIPT_DIR%\..") do set "PROJECT_ROOT=%%~fI"

REM ============================================================================
REM  Banner
REM ============================================================================
echo.
echo %PURPLE%======================================================================%NC%
echo %WHITE%%BOLD%   aiDaptiv Benchmark Suite - AIO Installer (Windows)%NC%
echo %GRAY%   All In One - Docker - Auto Setup%NC%
echo %PURPLE%======================================================================%NC%
echo.

REM ============================================================================
REM  Kiem tra quyen admin
REM ============================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %YELLOW%======================================================================%NC%
    echo %YELLOW%   CANH BAO: Script dang chay KHONG co quyen Admin.%NC%
    echo %YELLOW%   Mot so buoc cai dat co the can quyen Administrator.%NC%
    echo %YELLOW%   De bao dam, click phai script va chon "Run as Administrator"%NC%
    echo %YELLOW%======================================================================%NC%
    echo.
    echo %WHITE%  Ban co muon tiep tuc khong? (Y/N)%NC%
    choice /C YN /N /M "  Chon (Y/N): "
    if errorlevel 2 (
        echo.
        echo %RED%  Da huy. Vui long chay lai voi quyen Administrator.%NC%
        pause
        exit /b 1
    )
)

REM ============================================================================
REM  Step 1: Kiem tra Docker
REM ============================================================================
echo.
echo %CYAN%======================================================%NC%
echo %WHITE%%BOLD%  Step 1/5 - Kiem tra Docker Desktop%NC%
echo %CYAN%======================================================%NC%

where docker >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%  [OK] Docker da duoc cai dat.%NC%
    docker --version
    goto :check_daemon
)

echo.
echo %WHITE%  Docker chua duoc cai dat tren may nay.%NC%
echo.

REM ---- Thu cai qua winget ----
where winget >nul 2>&1
if %errorlevel% equ 0 (
    echo %YELLOW%======================================================================%NC%
    echo %YELLOW%   CAI DAT DOCKER DESKTOP QUA WINGET%NC%
    echo %YELLOW%                                                                      %NC%
    echo %YELLOW%   Windows se hien popup UAC yeu cau quyen admin.%NC%
    echo %YELLOW%   Vui long nhan "Yes" / "Allow" de tiep tuc.%NC%
    echo %YELLOW%======================================================================%NC%
    echo.
    echo %WHITE%  Dang cai Docker Desktop...%NC%

    winget install -e --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements

    if !errorlevel! equ 0 (
        echo %GREEN%  [OK] Docker Desktop da cai thanh cong qua winget.%NC%
    ) else (
        echo %RED%  [ERROR] Cai Docker qua winget that bai.%NC%
        goto :manual_docker_install
    )

    goto :check_wsl
) else (
    goto :manual_docker_install
)

:manual_docker_install
echo.
echo %YELLOW%======================================================================%NC%
echo %YELLOW%   KHONG TIM THAY WINGET%NC%
echo %YELLOW%                                                                      %NC%
echo %YELLOW%   Vui long tai va cai Docker Desktop thu cong:                       %NC%
echo %YELLOW%   https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe%NC%
echo %YELLOW%                                                                      %NC%
echo %YELLOW%   Sau khi cai xong, chay lai script nay.                            %NC%
echo %YELLOW%======================================================================%NC%
echo.

REM Mo trang download trong browser
echo %WHITE%  Dang mo trang tai Docker Desktop...%NC%
start "" "https://www.docker.com/products/docker-desktop/"

echo.
echo %WHITE%  Nhan phim bat ky sau khi da cai Docker Desktop...%NC%
pause >nul

REM Kiem tra lai
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%  [ERROR] Van khong tim thay Docker. Vui long cai dat va chay lai script.%NC%
    pause
    exit /b 1
)

:check_wsl
REM ============================================================================
REM  Kiem tra WSL2 (Docker Desktop can WSL2 hoac Hyper-V)
REM ============================================================================
echo.
echo %WHITE%  Kiem tra WSL2...%NC%
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %YELLOW%======================================================================%NC%
    echo %YELLOW%   CANH BAO: WSL2 CO THE CHUA DUOC BAT%NC%
    echo %YELLOW%                                                                      %NC%
    echo %YELLOW%   Docker Desktop can WSL2 hoac Hyper-V de chay.                     %NC%
    echo %YELLOW%   Neu Docker khong khoi dong duoc, chay lenh sau                    %NC%
    echo %YELLOW%   trong PowerShell (Admin):                                         %NC%
    echo %YELLOW%                                                                      %NC%
    echo %YELLOW%     wsl --install                                                   %NC%
    echo %YELLOW%                                                                      %NC%
    echo %YELLOW%   Sau do RESTART may va chay lai script nay.                        %NC%
    echo %YELLOW%======================================================================%NC%
    echo.
) else (
    echo %GREEN%  [OK] WSL2 da duoc bat.%NC%
)

REM ============================================================================
REM  Step 2: Kiem tra Docker daemon
REM ============================================================================
:check_daemon
echo.
echo %CYAN%======================================================%NC%
echo %WHITE%%BOLD%  Step 2/5 - Kiem tra Docker daemon%NC%
echo %CYAN%======================================================%NC%

docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%  [OK] Docker daemon dang chay.%NC%
    goto :prepare_env
)

echo %YELLOW%  [WARN] Docker daemon chua khoi dong.%NC%
echo %WHITE%  Dang mo Docker Desktop...%NC%

REM Thu mo Docker Desktop
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" 2>nul
if %errorlevel% neq 0 (
    start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" 2>nul
)

echo.
echo %YELLOW%======================================================================%NC%
echo %YELLOW%   DANG CHO DOCKER KHOI DONG%NC%
echo %YELLOW%                                                                      %NC%
echo %YELLOW%   Docker Desktop dang khoi dong. Lan dau co the mat 1-2 phut.       %NC%
echo %YELLOW%   Windows co the hien popup UAC - vui long chap nhan.               %NC%
echo %YELLOW%======================================================================%NC%
echo.

REM Doi Docker daemon san sang (toi da 120s)
set /a "max_wait=120"
set /a "waited=0"

:wait_docker_loop
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo %GREEN%  [OK] Docker daemon da san sang.%NC%
    goto :prepare_env
)

if %waited% geq %max_wait% (
    echo.
    echo %RED%  [ERROR] Docker daemon khong khoi dong duoc sau %max_wait%s.%NC%
    echo %RED%  Vui long mo Docker Desktop thu cong va chay lai script.%NC%
    pause
    exit /b 1
)

timeout /t 3 /nobreak >nul
set /a "waited+=3"
echo   Dang doi... %waited%s
goto :wait_docker_loop

REM ============================================================================
REM  Step 3: Chuan bi moi truong
REM ============================================================================
:prepare_env
echo.
echo %CYAN%======================================================%NC%
echo %WHITE%%BOLD%  Step 3/5 - Chuan bi moi truong%NC%
echo %CYAN%======================================================%NC%

REM Copy .env neu chua co
if not exist "%SCRIPT_DIR%\.env" (
    copy "%SCRIPT_DIR%\.env.example" "%SCRIPT_DIR%\.env" >nul
    echo %GREEN%  [OK] Da tao file .env tu .env.example%NC%
    echo %WHITE%  Ban co the chinh sua: %SCRIPT_DIR%\.env%NC%
) else (
    echo %GREEN%  [OK] File .env da ton tai.%NC%
)

REM Copy .dockerignore vao project root
if not exist "%PROJECT_ROOT%\.dockerignore" (
    copy "%SCRIPT_DIR%\.dockerignore" "%PROJECT_ROOT%\.dockerignore" >nul
    echo %GREEN%  [OK] Da copy .dockerignore vao project root%NC%
)

echo.
echo %GRAY%  Project root : %PROJECT_ROOT%%NC%
echo %GRAY%  AIO dir      : %SCRIPT_DIR%%NC%
echo %GRAY%  Compose file : %SCRIPT_DIR%\docker-compose.yaml%NC%

REM ============================================================================
REM  Step 4: Build Docker Image & Khoi dong
REM ============================================================================
echo.
echo %CYAN%======================================================%NC%
echo %WHITE%%BOLD%  Step 4/5 - Build Docker Image ^& Khoi dong services%NC%
echo %CYAN%======================================================%NC%

echo.
echo %WHITE%  Dang build Docker image va khoi dong containers...%NC%
echo %WHITE%  Lan dau co the mat 3-5 phut.%NC%
echo.

cd /d "%PROJECT_ROOT%"

REM Kiem tra container cu
docker ps -a --format "{{.Names}}" 2>nul | findstr /C:"aidaptiv-app" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo %YELLOW%======================================================================%NC%
    echo %YELLOW%   CONTAINERS CU DA TON TAI%NC%
    echo %YELLOW%======================================================================%NC%
    echo.
    choice /C YN /N /M "  Rebuild va khoi dong lai? (Y/N): "
    if errorlevel 2 (
        echo %WHITE%  Giu nguyen containers hien tai. Dam bao chung dang chay...%NC%
        docker compose -f "%SCRIPT_DIR%\docker-compose.yaml" up -d
    ) else (
        echo %WHITE%  Dung containers cu...%NC%
        docker compose -f "%SCRIPT_DIR%\docker-compose.yaml" down 2>nul
        echo %WHITE%  Rebuild...%NC%
        docker compose -f "%SCRIPT_DIR%\docker-compose.yaml" up --build -d
    )
) else (
    docker compose -f "%SCRIPT_DIR%\docker-compose.yaml" up --build -d
)

if %errorlevel% neq 0 (
    echo.
    echo %RED%  [ERROR] Docker Compose that bai!%NC%
    echo %RED%  Kiem tra logs: docker compose -f "%SCRIPT_DIR%\docker-compose.yaml" logs%NC%
    pause
    exit /b 1
)

REM ============================================================================
REM  Step 5: Kiem tra trang thai
REM ============================================================================
echo.
echo %CYAN%======================================================%NC%
echo %WHITE%%BOLD%  Step 5/5 - Kiem tra trang thai%NC%
echo %CYAN%======================================================%NC%

echo %WHITE%  Dang doi ung dung khoi dong...%NC%

REM Doc port tu .env
set "APP_PORT=8443"
for /f "tokens=2 delims==" %%a in ('findstr /C:"AIDAPTIV_APP_PORT" "%SCRIPT_DIR%\.env" 2^>nul') do (
    set "APP_PORT=%%a"
)

REM Doi app san sang (toi da 60s)
set /a "max_app_wait=60"
set /a "app_waited=0"

:wait_app_loop
curl -sf "http://localhost:%APP_PORT%/" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo %GREEN%  [OK] Ung dung da san sang!%NC%
    goto :show_result
)

if %app_waited% geq %max_app_wait% (
    echo.
    echo %YELLOW%  [WARN] Ung dung chua phan hoi sau %max_app_wait%s.%NC%
    echo %WHITE%  Kiem tra logs: docker compose -f AIO\docker-compose.yaml logs app%NC%
    goto :show_result
)

timeout /t 2 /nobreak >nul
set /a "app_waited+=2"
echo   Dang doi... %app_waited%s
goto :wait_app_loop

:show_result
echo.
echo %GRAY%  Trang thai containers:%NC%
docker compose -f "%SCRIPT_DIR%\docker-compose.yaml" ps

REM ============================================================================
REM  Ket qua
REM ============================================================================
echo.
echo %GREEN%======================================================================%NC%
echo %GREEN%   CAI DAT HOAN TAT!%NC%
echo %GREEN%======================================================================%NC%
echo.
echo %WHITE%   Web UI:      %CYAN%http://localhost:%APP_PORT%%NC%
echo %WHITE%   PostgreSQL:  %CYAN%localhost:5432%NC%
echo.
echo %GRAY%   Lenh huu ich:%NC%
echo %WHITE%   Xem logs:    %GRAY%docker compose -f AIO\docker-compose.yaml logs -f%NC%
echo %WHITE%   Dung:        %GRAY%docker compose -f AIO\docker-compose.yaml down%NC%
echo %WHITE%   Khoi dong:   %GRAY%docker compose -f AIO\docker-compose.yaml up -d%NC%
echo %WHITE%   Rebuild:     %GRAY%docker compose -f AIO\docker-compose.yaml up --build -d%NC%
echo.
echo %GREEN%======================================================================%NC%
echo.

REM Mo browser tu dong
echo %WHITE%  Dang mo trinh duyet...%NC%
start "" "http://localhost:%APP_PORT%"

echo.
echo %WHITE%  Nhan phim bat ky de dong cua so nay...%NC%
pause >nul
