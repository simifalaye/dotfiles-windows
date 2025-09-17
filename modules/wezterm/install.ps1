. "$PSScriptRoot\..\..\lib\common.ps1"

# Install
Install-AppIfMissing -AppId "wez.wezterm"

# Stow dots
Stow-Dotfiles -PackageName "wezterm"
