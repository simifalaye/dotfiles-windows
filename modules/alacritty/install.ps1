. "$PSScriptRoot\..\..\lib\common.ps1"

# Install
Install-AppIfMissing -AppId "Alacritty.Alacritty"

# Stow dots
Stow-Dotfiles -PackageName "alacritty"

# Setup theme watcher
$taskName = "Alacritty Theme Watcher"
$script = "$PSScriptRoot\scripts\theme-watcher.ps1"
function Setup-ThemeSwitcher {
  if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Write-Info "Scheduled task '$taskName' already exists."
    return
  }

  $action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""

  $trigger = New-ScheduledTaskTrigger -AtLogOn

  $principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Highest

  Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Switch Alacritty theme based on Windows system theme"

  Write-Info "Scheduled task '$taskName' created."

  Start-ScheduledTask -TaskName $taskName

  Write-Info "Started task '$taskName'."
}
Setup-ThemeSwitcher
