. "$PSScriptRoot\..\..\lib\common.ps1"

# Install
Install-AppIfMissing -AppId "Alacritty.Alacritty"

# Stow dots
Stow-Dotfiles -PackageName "alacritty"
