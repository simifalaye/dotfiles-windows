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

# TODO: Evaluate
function Stow-Dotfiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [string]$DotfilesDir = "$PSScriptRoot\..",
        [string]$TargetDir = $HOME
    )

    $PackagePath = Join-Path $DotfilesDir $PackageName

    if (-not (Test-Path $PackagePath)) {
        Write-Error "Package '$PackageName' does not exist in dotfiles directory: $PackagePath"
        return
    }

    Get-ChildItem -Path $PackagePath -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($PackagePath.Length).TrimStart('\')
        $targetPath = Join-Path $TargetDir $relativePath

        if (Test-Path $targetPath -or (Test-Path $targetPath -PathType Container)) {
            Write-Warning "Skipping existing item: $targetPath"
        } else {
            $parentDir = Split-Path $targetPath -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }

            if ($_.PSIsContainer) {
                # Create a directory junction
                cmd /c "mklink /J `"$targetPath`" `"$($_.FullName)`"" | Out-Null
                Write-Host "Linked dir: $relativePath"
            } else {
                # Create a symbolic link
                cmd /c "mklink `"$targetPath`" `"$($_.FullName)`"" | Out-Null
                Write-Host "Linked file: $relativePath"
            }
        }
    }
}

function Unstow-Dotfiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [string]$DotfilesDir = "$PSScriptRoot\..",
        [string]$TargetDir = $HOME
    )

    $PackagePath = Join-Path $DotfilesDir $PackageName

    if (-not (Test-Path $PackagePath)) {
        Write-Error "Package '$PackageName' does not exist in dotfiles directory: $PackagePath"
        return
    }

    Get-ChildItem -Path $PackagePath -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($PackagePath.Length).TrimStart('\')
        $targetPath = Join-Path $TargetDir $relativePath

        if (Test-Path $targetPath -or (Test-Path $targetPath -PathType Container)) {
            Remove-Item $targetPath -Force -Recurse
            Write-Host "Removed link: $relativePath"
        } else {
            Write-Warning "Link not found: $targetPath"
        }
    }
}
