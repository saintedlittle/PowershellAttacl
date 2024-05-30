param (
    [string]$newUrl,
    [string]$newFolderName
)

# Определение путей
$sourceScriptPath = "work.ps1"
$modifiedScriptPath = "temp.ps1"
$outputExePath = "OutputExecutable.exe"
$certPath = "Certificate.pfx"
$pfxPassword = "PENISPENISXUIPIZDA"

# Установка модуля ps2exe, если он не установлен
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Install-Module -Name ps2exe -Force -Scope CurrentUser
}

# Создание самоподписанного сертификата
$cert = New-SelfSignedCertificate -DnsName "saintedlittleCorporation" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -NotAfter (Get-Date).AddYears(5)
$pwd = ConvertTo-SecureString -String $pfxPassword -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $pwd

$scriptContent = Get-Content -Path $sourceScriptPath

# Заменить значения переменных
$scriptContent = $scriptContent -replace '\$url = ".*"', "\$url = `"$newUrl`""
$scriptContent = $scriptContent -replace '\$FolderName = ".*"', "\$FolderName = `"$newFolderName`""

# Сохранить изменённый скрипт
Set-Content -Path $modifiedScriptPath -Value $scriptContent

# Сборка в exe с использованием ps2exe
Invoke-Expression "ps2exe.ps1 -inputFile $modifiedScriptPath -outputFile $outputExePath -requireAdmin"

# Подписание исполняемого файла
Set-AuthenticodeSignature -FilePath $outputExePath -Certificate (Get-PfxCertificate -FilePath $certPath -Password $pwd)

# Удаление временного файла
Remove-Item -Path $modifiedScriptPath -Force
