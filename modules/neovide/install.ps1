. "$PSScriptRoot\..\..\lib\common.ps1"

# Install
Install-AppIfMissing -AppId "Neovide.Neovide"

# Stow dots
Stow-Dotfiles -PackageName "neovide"
