. "$PSScriptRoot\..\..\lib\common.ps1"

Write-Info "Installing nerd fonts."
& ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1'))) -Confirm:$false -Scope AllUsers -Name jetbrains-mono
