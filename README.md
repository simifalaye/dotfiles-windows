<h1 align="center">Dotfiles Windows</h1>
<p align="center">My dotfiles for windows</p>
<p align="center">
  <img src="https://i.imgur.com/pVGr7tX.png">
</p>

# Pre-Install Requirements

Must set windows execution policy to allow script execution:

`Set-ExecutionPolicy Unrestricted`

# Install

- Open powershell **as Administrator** 
- Run bootstrap:
```powershell
iex ((new-object net.webclient).DownloadString('https://raw.github.com/simifalaye/dotfiles-windows/main/bootstrap.ps1'))
```
- Machine may reboot at the end (for enabling wsl)
- Open powershell again **as Administrator**
- Cd to profile dir: `cd %USERPROFILE%/.dotfiles`
- Run installer: `.\install.ps1`
