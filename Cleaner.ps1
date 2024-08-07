function cleaner() {
	$ErrorActionPreference = 'SilentlyContinue';

	[console]::writeline("Using Disk Cleanup with custom configuration")
	
	$volumeCache = @{
		"Active Setup Temp Folders"      = 2
		"BranchCache"                    = 2
		"Delivery Optimization Files"    = 2
		"Device Driver Packages"         = 2
		# "Diagnostic Data Viewer database files" = 2
		"Downloaded Program Files"       = 2
		"Internet Cache Files"           = 2
		"Language Pack"                  = 2
		"Offline Pages Files"            = 2
		"Old ChkDsk Files"               = 2
		# "RetailDemo Offline Content" = 2
		"Setup Log Files"                = 2
		"System error memory dump files" = 2
		"System error minidump files"    = 2
		"Temporary Setup Files"          = 2
		"Temporary Sync Files"           = 2
    		"Update Cleanup"                 = 2
    		"Upgrade Discarded Files"        = 2
   		"User file versions"             = 2
    		"Windows Defender"               = 2
    		"Windows Error Reporting Files"  = 2
    		"Windows Reset Log Files"        = 2
    		"Windows Upgrade Log Files"      = 2
		}
	

	$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches";

	foreach ($item in $volumeCache.GetEnumerator()) {
		$keyPath = Join-Path $registryPath $item.Key
		if (Test-Path $keyPath) {
			New-ItemProperty -Path $keyPath -Name StateFlags1337 -Value $item.Value -PropertyType DWord > $Null
		}
	}

	Start-Process -FilePath "$env:SystemRoot\system32\cleanmgr.exe" -ArgumentList "/sagerun:1337" -Wait:$false


	[console]::writeline("Cleaning up Event Logs")
	Get-EventLog -LogName * | ForEach-Object { Clear-EventLog $_.Log }

	[console]::writeline("Disabling Reserved Storage")
	Set-WindowsReservedStorageState -State Disabled

	Stop-Service -Name "bits" -Force > $Null
	Stop-Service -Name "appidsvc" -Force > $Null
	Stop-Service -Name "dps" -Force > $Null
	Stop-Service -Name "wuauserv" -Force > $Null
	Stop-Service -Name "cryptsvc" -Force > $Null

	[console]::writeline("Cleaning up leftovers")

	$foldersToRemove = @(
	"CbsTemp",
	"Logs",
	"SoftwareDistribution",
	"System32\LogFiles",
	"System32\LogFiles\WMI,"
	"System32\SleepStudy",
	"System32\sru",
	"System32\WDI\LogFiles",
	"System32\winevt\Logs",
	"SystemTemp",
	"Temp"
	
	# "WinSxS\Backup"
	# # "Panther",
	# # "Prefetch"
	)

	foreach ($folderName in $foldersToRemove) {
		$folderPath = Join-Path $env:SystemRoot $folderName
		if (Test-Path $folderPath) {
			Remove-Item -Path "$folderPath\*" -Force -Recurse > $Null
			}
			}
	
	# Remove-Item -Path "C:\Program Files\WindowsApps\MicrosoftWindows.Client.WebExperience*" -Recurse -Force

	Get-ChildItem -Path "$env:SystemRoot" -Filter *.log -File -Recurse -Force | Remove-Item -Recurse -Force >$Null

	[console]::writeline("Cleaning up %TEMP%")
	Get-ChildItem -Path "$env:TEMP" -Exclude "AME" | Remove-Item -Recurse -Force

	# Just in case
	Start-ScheduledTask -TaskPath "\Microsoft\Windows\DiskCleanup\" -TaskName "SilentCleanup"

	# [console]::writeline("Cleaning up Retail Demo Content")
	# Start-ScheduledTask -TaskPath "\Microsoft\Windows\RetailDemo\" -TaskName "CleanupOfflineContent"

	# [console]::writeline("Cleaning up the WinSxS Components")
	# DISM /Online /Cleanup-Image /StartComponentCleanup
}
