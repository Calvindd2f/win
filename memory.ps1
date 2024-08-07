Disable-MMAgent -MemoryCompression #Memory Compression

(gcim -ClassName Win32_Process| where {$_.Name -notlike "System" -and $_.Name -notlike "svchost.exe"}).Dispose()    # Kill all non-system processes

taskkill /F /IM explorer.exe                                                                                        # Kill explorer
Start-Process explorer.exe

ipconfig /flushdns                                                                                                  # Flush DNS

Remove-Item -Path "$env:TEMP\*" -Recurse -Force                                                                     # Remove temporary files

# Disable pagefile
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
$computersys.AutomaticManagedPagefile = $False
$computersys.Put()
# Set pagefile to none
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name='C:\\pagefile.sys'"
$pagefile.Delete()
# Re-enable pagefile
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
$computersys.AutomaticManagedPagefile = $True
$computersys.Put()

Get-Process | Where-Object { $_.ProcessName -notmatch 'svchost|explorer|csrss|lsass' } | Stop-Process -Force        # Kill all non-system processes (ez restart)