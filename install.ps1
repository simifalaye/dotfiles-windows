# Ensure script runs with admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

function RunModule {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    . "$PSScriptRoot\modules\$ModuleName\install.ps1"
}

RunModule -ModuleName "settings"
RunModule -ModuleName "default-apps"
RunModule -ModuleName "chrome"
RunModule -ModuleName "wezterm"
RunModule -ModuleName "wsl"

Write-Host "Bootstrap complete! Note: Some changes may require a restart to take effect." -ForegroundColor "Green"
