function Write-Info($Msg) {
    Write-Host "[INFO] $Msg" -ForegroundColor Cyan
}

function Write-Warn($Msg) {
    Write-Host "[WARN] $Msg" -ForegroundColor Yellow
}

function Write-Err($Msg) {
    Write-Host "[ERROR] $Msg" -ForegroundColor Red
}

function Install-AppIfMissing {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppId
    )

    $isInstalled = winget list --id $AppId 2>$null | Select-String $AppId
    if (-not $isInstalled) {
        Write-Info "Installing $AppId..."
        winget install --id $AppId --accept-package-agreements --accept-source-agreements
    }
}

function Test-PendingReboot {
    $pending = $false
    $reason = ""

    # Windows Update pending reboot
    $wuReboot = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue
    if ($wuReboot) {
        $pending = $true
        $reason = "Windows Update"
    }

    # Component-Based Servicing (CBS) pending reboot
    $cbsReboot = Get-Item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' -ErrorAction SilentlyContinue
    if ($cbsReboot) {
        $pending = $true
        $reason = "Component-Based Servicing"
    }

    # Pending file rename operations
    $pendingFileRename = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
    if ($pendingFileRename -and $pendingFileRename.PendingFileRenameOperations) {
        $pending = $true
        $reason = "File rename operations"
    }

    # SCCM/WSUS reboot flag (optional)
    $sccmReboot = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootRequired' -ErrorAction SilentlyContinue
    if ($sccmReboot) {
        $pending = $true
        $reason = "SCCM"
    }

    return [pscustomobject]@{
        Pending = $pending
        Reason = $reason
    }
}
