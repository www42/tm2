# Prerequisites: Windows Terminat and winget
winget --version     # Should be v1.28.240 or above

# Install Winget Packages
$packages = @(
    "Git.Git",
    "GitHub.cli"
    "Microsoft.Bicep",
    "Microsoft.AzureCLI",
    "Microsoft.PowerShell",
    "Microsoft.VisualStudioCode"
    "microsoft.azd"
    "JanDeDobbeleer.OhMyPosh"
    "Anthropic.Claude"
    "calibre.calibre"
    "Docker.DockerDesktop"
    "Microsoft.PowerToys"
    "Microsoft.Sysinternals.ProcessExplorer"
    "VideoLAN.VLC"
    "Microsoft.WindowsTerminal"
    "Obsidian.Obsidian"
    "Postman.Postman"
    "KeePassXCTeam.KeePassXC"
    "ElementLabs.LMStudio"
    "Greenshot.Greenshot"
    "Elgato.ControlCenter"
    "Elgato.StreamDeck"
)

foreach ($pkg in $packages) {
    Write-Host "Installing $pkg ..." -ForegroundColor Cyan
    winget install --id $pkg --exact --silent --accept-package-agreements --accept-source-agreements
}


# Reload PATH Variable
Write-Host "Refreshing PATH ..." -ForegroundColor Cyan
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")


# Install VS Code Extensions
$extensions = @(
    "ms-vscode.powershell",
    "ms-vscode.azurecli",
    "ms-azuretools.vscode-bicep",
    "redhat.vscode-yaml",
    "eriklynd.json-tools",
    "tomoki1207.pdf"
)

foreach ($ext in $extensions) {
    Write-Host "Installing Extension $ext ..." -ForegroundColor Cyan
    $env:NODE_NO_WARNINGS = "1"
    code --install-extension $ext --force
} 


# Install PowerShell Modules
$PSVersionTable    # Should be 7.6.3 or above

$modules = @(
    "Az",
    "Microsoft.Entra",
    "Microsoft.Graph"
)

foreach ($mod in $modules) {
    Write-Host "Installing Module $mod ..." -ForegroundColor Cyan
    Install-Module $mod -Force -AllowClobber -Scope CurrentUser
}
