# Ensure script runs with admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

. "$PSScriptRoot\lib\common.ps1"

function RunModule {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    . "$PSScriptRoot\modules\$ModuleName\install.ps1"
}

RunModule -ModuleName "settings"
RunModule -ModuleName "default-apps"
RunModule -ModuleName "alacritty"
# RunModule -ModuleName "chrome"
RunModule -ModuleName "nerd-fonts"
RunModule -ModuleName "powertoys"
# RunModule -ModuleName "wezterm"
# RunModule -ModuleName "windows-terminal"
RunModule -ModuleName "win32yank"
RunModule -ModuleName "wsl"

Write-Host "Bootstrap complete!" -ForegroundColor "Green"
$rebootRequired = Test-PendingReboot
if ($rebootRequired.Pending) {
    Write-Warn "Reboot pending due to: $($rebootRequired.Reason)"
}
