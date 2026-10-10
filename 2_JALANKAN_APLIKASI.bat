@echo off
title JALANKAN APLIKASI KOPMA - kopma_npm
echo ==================================================
echo   1) Menyalakan MySQL (XAMPP)...
echo ==================================================
taskkill /F /IM mysqld.exe >nul 2>&1
timeout /t 2 >nul
start "" /B "C:\xampp\mysql\bin\mysqld.exe" --defaults-file=C:\xampp\mysql\bin\my.ini --standalone
timeout /t 8 >nul

netstat -an | findstr "3306" | findstr "LISTENING" >nul
if %errorlevel%==0 (
    echo [OK] MySQL JALAN.
) else (
    echo [PERINGATAN] MySQL belum siap. Tutup jendela ini, buka XAMPP Control Panel, Start MySQL, lalu jalankan lagi.
    pause
    exit /b
)

echo.
echo ==================================================
echo   2) Menjalankan server Laravel...
echo      Buka browser ke: http://127.0.0.1:8000
echo      Tekan Ctrl+C di jendela ini untuk berhenti.
echo ==================================================
echo.

cd /d "%~dp0laravel_kopma"
"C:\xampp\php\php.exe" artisan serve

pause
