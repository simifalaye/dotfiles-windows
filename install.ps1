# Ensure script runs with admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

. "$PSScriptRoot\modules\settings\install.ps1"
. "$PSScriptRoot\modules\default-apps\install.ps1"
. "$PSScriptRoot\modules\wezterm\install.ps1"
. "$PSScriptRoot\modules\wsl\install.ps1"

Write-Host "Bootstrap complete! Note: Some changes may require a restart to take effect." -ForegroundColor "Green"
