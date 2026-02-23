# Uniam installer for Windows (PowerShell)
# Usage: irm https://github.com/pdasilem/uniam/releases/latest/download/install.ps1 | iex

$ErrorActionPreference = "Stop"
$Repo = "pdasilem/uniam"
$Binary = "uniam.exe"

# Detect architecture
$Arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else {
    Write-Error "Unsupported architecture. Only x86-64 is supported."
    exit 1
}

# Ensure TLS 1.2 is used for GitHub downloads (required for older PowerShell 5.1)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get latest release version
Write-Host "Fetching latest release..."
$Release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
$Version = $Release.tag_name

if (-not $Version) {
    Write-Error "Failed to fetch latest version."
    exit 1
}

$Filename = "uniam-windows-$Arch.exe"
$Url = "https://github.com/$Repo/releases/download/$Version/$Filename"

# Install directory
$InstallDir = "$env:LOCALAPPDATA\Programs\uniam"
$InstallPath = Join-Path $InstallDir $Binary

Write-Host "Downloading uniam $Version for windows/$Arch..."
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Invoke-WebRequest -Uri $Url -OutFile $InstallPath

# Add to user PATH if not already present
$CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($CurrentPath -notlike "*$InstallDir*") {
    Write-Host "Adding $InstallDir to user PATH..."
    SETX PATH "$CurrentPath;$InstallDir" | Out-Null
    Write-Host ""
    Write-Host "PATH updated. You must restart your terminal for it to take effect."
} else {
    Write-Host "$InstallDir is already in PATH."
}

Write-Host ""
Write-Host "Installed to: $InstallPath"
Write-Host ""
Write-Host "Done! Open a new terminal and run: uniam init"
