@echo off
title Laravel KOPMA
echo ===================================================
echo   Sistem Informasi KOPMA (SI-KOPMA) - Localhost
echo ===================================================
echo.
cd /d "%~dp0"

echo [1/3] Memastikan MySQL aktif...
start /b "" "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini" --standalone

echo [2/4] Menjalankan Realtime Auto-Sync Watcher (Model Streamlit)...
start /b "" powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0sync_watcher.ps1"

echo [3/4] Membuka browser ke http://localhost:8000 ...
timeout /t 2 /nobreak >nul
start "" "http://localhost:8000"

echo [4/4] Menjalankan server Laravel...
echo Tekan Ctrl+C jika ingin mematikan server.
echo.
"C:\xampp\php\php.exe" artisan serve --host=127.0.0.1 --port=8000
pause

