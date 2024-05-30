$serviceName = "StealerHttpServer"

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Для удаления службы PowerShell нужно запускать от имени администратора."
    Exit
}

# Удаляем службу
Stop-Service -Name $serviceName -ErrorAction SilentlyContinue
Remove-Service -Name $serviceName
