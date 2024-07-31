function Repair-WMIRepository {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    begin {
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            throw "This function requires administrative privileges. Please run PowerShell as an administrator."
        }
    }

    process {
        try {
            if ($PSCmdlet.ShouldProcess("WMI Repository", "Repair")) {
                Write-Host "Stopping WMI-related services..." -ForegroundColor Yellow
                Stop-Service -Name Winmgmt -Force
                
                Write-Host "Salvaging WMI repository..." -ForegroundColor Yellow
                winmgmt /salvagerepository %windir%\System32\wbem
                
                Write-Host "Verifying WMI repository..." -ForegroundColor Yellow
                winmgmt /verifyrepository
                
                Write-Host "Rebuilding WMI repository..." -ForegroundColor Yellow
                Get-ChildItem $env:SystemRoot\System32\wbem -Filter *.mof -Recurse | ForEach-Object {
                    mofcomp $_.FullName
                }
                
                Get-ChildItem $env:SystemRoot\System32\wbem -Filter *.dll -Recurse | ForEach-Object {
                    regsvr32 /s $_.FullName
                }
                
                Write-Host "Starting WMI service..." -ForegroundColor Yellow
                Start-Service -Name Winmgmt
                
                Write-Host "WMI repository repair completed successfully." -ForegroundColor Green
            }
        }
        catch {
            Write-Error "An error occurred while repairing the WMI repository: $_"
        }
    }
}
