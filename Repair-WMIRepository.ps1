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
                [console]::writeline("Stopping WMI-related services...")
                Stop-Service -Name Winmgmt -Force
                
                [console]::writeline("Salvaging WMI repository...")
                winmgmt /salvagerepository %windir%\System32\wbem
                
                [console]::writeline("Verifying WMI repository...")
                winmgmt /verifyrepository
                
                [console]::writeline("Rebuilding WMI repository...")
                Get-ChildItem $env:SystemRoot\System32\wbem -Filter *.mof -Recurse | ForEach-Object {
                    mofcomp $_.FullName
                }
                
                Get-ChildItem $env:SystemRoot\System32\wbem -Filter *.dll -Recurse | ForEach-Object {
                    regsvr32 /s $_.FullName
                }
                
                [console]::writeline("Starting WMI service...")
                Start-Service -Name Winmgmt
                
                [console]::writeline("WMI repository repair completed successfully.")
            }
        }
        catch {
            Write-Error "An error occurred while repairing the WMI repository: $_"
        }
    }
}
