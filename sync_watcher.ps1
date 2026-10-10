# Script Auto-Sync Realtime Model Streamlit untuk Laravel KOPMA
$projectPath = $PSScriptRoot
Set-Location $projectPath

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SI-KOPMA Realtime Auto-Sync Watcher (Model Streamlit)  " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Memantau perubahan file di Antigravity..." -ForegroundColor Yellow
Write-Host "Setiap ada perubahan kode atau database/seeder, sistem akan otomatis sinkron!" -ForegroundColor DarkGray

$lastDbTime = [DateTime]::MinValue
$dbFiles = Get-ChildItem -Path "$projectPath\database" -Recurse -Filter "*.php" -ErrorAction SilentlyContinue
if ($dbFiles) {
    $lastDbTime = ($dbFiles | Measure-Object -Property LastWriteTime -Maximum).Maximum
}

while ($true) {
    Start-Sleep -Seconds 1
    
    # Periksa perubahan file database (seeder / migration)
    $currentDbFiles = Get-ChildItem -Path "$projectPath\database" -Recurse -Filter "*.php" -ErrorAction SilentlyContinue
    if ($currentDbFiles) {
        $currentMaxTime = ($currentDbFiles | Measure-Object -Property LastWriteTime -Maximum).Maximum
        if ($currentMaxTime -gt $lastDbTime) {
            $lastDbTime = $currentMaxTime
            Write-Host "`n[SYNC] Terdeteksi perubahan pada database/seeder ($($lastDbTime.ToString('HH:mm:ss')))..." -ForegroundColor Magenta
            Write-Host "[SYNC] Menjalankan 'php artisan migrate:fresh --seed' otomatis..." -ForegroundColor Cyan
            
            & "C:\xampp\php\php.exe" artisan migrate:fresh --seed
            
            $nowUnix = [DateTimeOffset]::Now.ToUnixTimeSeconds()
            Set-Content -Path "$projectPath\storage\framework\last_db_sync.txt" -Value $nowUnix -Force
            Write-Host "[SYNC SELESAI] Database dan data dummy berhasil disinkronkan secara realtime!`n" -ForegroundColor Green
        }
    }
}
