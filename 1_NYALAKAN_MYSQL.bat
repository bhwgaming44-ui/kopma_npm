@echo off
title NYALAKAN MySQL (XAMPP) - KOPMA kopma_npm
echo ==================================================
echo   Menyalakan MySQL / MariaDB dari XAMPP...
echo ==================================================
echo.

REM Pastikan tidak ada mysqld nyangkut yang bikin port 3306 bentrok
taskkill /F /IM mysqld.exe >nul 2>&1
timeout /t 2 >nul

REM Nyalakan MySQL (menggunakan my.ini bawaan XAMPP)
start "" /B "C:\xampp\mysql\bin\mysqld.exe" --defaults-file=C:\xampp\mysql\bin\my.ini --standalone

echo Menunggu MySQL siap (8 detik)...
timeout /t 8 >nul

REM Cek apakah port 3306 sudah terbuka
netstat -an | findstr "3306" | findstr "LISTENING" >nul
if %errorlevel%==0 (
    echo.
    echo [SUKSES] MySQL SUDAH JALAN di port 3306.
    echo Sekarang Anda bisa buka aplikasi Laravel.
) else (
    echo.
    echo [GAGAL] MySQL belum muncul di port 3306.
    echo Coba buka XAMPP Control Panel lalu klik Start pada MySQL.
)
echo.
pause
