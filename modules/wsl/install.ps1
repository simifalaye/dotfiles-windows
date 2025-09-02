. "$PSScriptRoot\..\..\lib\common.ps1"

# Make WSL output utf-8 encoding
$Env:WSL_UTF8 = '1'

#
# Setup/Install
#

Write-Info ":: Installing WSL..."

# Enable WSL and Virtual Machine Platform features if not already enabled
if (!(Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled" -or
        !(Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq "Enabled") {
    Write-Output "WSL must be enabled. Please run the enable-wsl.ps1 script first" -ForegroundColor "Red"
    exit 1
}
if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).RestartNeeded -or
        (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).RestartNeeded) {
    Write-Output "Machine needs to be restarted for wsl to be fully enabled" -ForegroundColor "Red"
    exit 1
}

# Set WSL version to 2 if not already set
$wslVersion = wsl --status 2>$null | Select-String "Default Version: 2"
if (-not $wslVersion) {
    Write-Output "Setting WSL default version to 2..."
    wsl --set-default-version 2
}

# Check if Ubuntu is installed
$ubuntuInstalled = wsl --list --verbose 2>$null | Select-String -Pattern "Ubuntu"
if (-not $ubuntuInstalled) {
    Write-Output "Installing Ubuntu..."
    wsl --install Ubuntu
}

# Install ssh keys
wsl -d Ubuntu -- bash -c "mkdir -p ~/.ssh && cp /mnt/c/Users/'$($env:USERNAME)'/.ssh/id* ~/.ssh && chmod 600 ~/.ssh/id* && chmod 700 ~/.ssh"
