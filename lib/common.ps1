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
        Write-Host "Installing $AppId..."
        winget install --id $AppId --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "$AppId is already installed."
    }
}
