$ErrorActionPreference = 'Stop'

# Setup params
param (
    [Parameter(Mandatory = $true)]
    [string]$SshEmail
)

# Ensure script runs with admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    exit 1
}

#
# Git
#

# Install git
$isGitInstalled = winget list --id Git.Git 2>$null | Select-String Git.Git
if (-not $isGitInstalled) {
    winget install --id Git.Git --accept-package-agreements --accept-source-agreements
    $env:Path += ";C:\Program Files\Git\cmd"
}

#
# SSH
#

# Generate SSH key if not exists
$sshDir = "$env:USERPROFILE\.ssh"
$sshKeyPath = Join-Path $sshDir "id_ed25519"

if (-not (Test-Path $sshKeyPath)) {
    Write-Host "SSH key not found. Generating a new ed25519 key..."  
    if (-not $SshEmail) {
        $SshEmail = Read-Host "Enter a SSH email to use"
    }
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir | Out-Null
    }
    Write-Host "SSH email: $SshEmail"

    ssh-keygen -t ed25519 -C $SshEmail -f $sshKeyPath
    Write-Host "`nSSH key generated at $sshKeyPath"
    Write-Host "`nAdd the following public key to your Git provider:"
    Get-Content "$sshKeyPath.pub"
    Read-Host "`nPress Enter after adding your SSH key to your Git provider"
}

#
# Dotfiles repo
#

# Clone the repo if not already cloned
$repoPath = "$env:USERPROFILE\.dotfiles"
$repoUrl = "git@github.com:simifalaye/dotfiles-windows.git"

if (-not (Test-Path $repoPath)) {
    Write-Host "Cloning dotfiles repo into $repoPath..."
    git clone $repoUrl $repoPath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nRepository successfully cloned."
    } else {
        Write-Host "`nFailed to clone the repository. Check your SSH access and repo URL."
    }
}

#
# WSL
#

Write-Host "Enabling WSL..." -ForegroundColor "Blue"

# Enable WSL and Virtual Machine Platform features if not already enabled
if (!(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
    Write-Output "Enabling WSL..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
}
if (!(Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq "Enabled") {
    Write-Output "Enabling Virtual Machine Platform..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
}

# Restart the system if required
if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).RestartNeeded -or
    (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).RestartNeeded) {
    Write-Output "Restarting the system to apply changes..." -ForegroundColor "Blue"
    Write-Output "Save any necessary work before restart OR abort now" -ForegroundColor "Blue"
    Write-Output "Press Enter to continue..." -ForegroundColor "Blue"
    [void][System.Console]::ReadLine()

    Write-Host "Restarting..."
    Restart-Computer -Force
} else {
    Write-Host "WSL Already enabled"
}



