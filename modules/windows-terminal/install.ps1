. "$PSScriptRoot\..\..\lib\common.ps1"

# Install
Install-AppIfMissing -AppId "Microsoft.WindowsTerminal"

# Stow dots
Stow-Dotfiles -PackageName "windows-terminal"
