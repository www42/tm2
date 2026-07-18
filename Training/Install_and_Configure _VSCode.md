# Install and configure VS Code 🔢

## 1. Prerequisites: Windows Terminal and winget

<img src="./media/Install_and_configure_VSCode_10.png" alt="Start with Terminal" width="500">

```powershell
winget --version     # Should be v1.28.240 or above
```

<br>


## 2. Install VS Code and some more packages

### Install Packages

```powershell
$packages = @(
    "Git.Git",
    "Microsoft.Bicep",
    "Microsoft.AzureCLI",
    "Microsoft.PowerShell",
    "Microsoft.VisualStudioCode"
)

foreach ($pkg in $packages) {
    Write-Host "Installing $pkg ..." -ForegroundColor Cyan
    winget install --id $pkg --exact --silent --accept-package-agreements --accept-source-agreements
}
```

### Reload PATH variable

```powershell
Write-Host "Refreshing PATH ..." -ForegroundColor Cyan
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

```

### Install VS Code extensions

```powershell
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
```

<br>

## 3. Install Modules (PowerShell 7)

### Start PowerShell 7, prove it's 7

<img src="./media/Install_and_configure_VSCode_20.png" alt="Ignore GitHub Copilot" width="500">

```powershell
$PSVersionTable    # Should be 7.6.3 or above
```

### Install Modules (this takes some time ☕)

```powershell
$modules = @(
    "Az",
    "Microsoft.Entra",
    "Microsoft.Graph"
)

foreach ($mod in $modules) {
    Write-Host "Installing Module $mod ..." -ForegroundColor Cyan
    Install-Module $mod -Force -AllowClobber -Scope CurrentUser
}
```

```powershell

Get-Module -ListAvailable az,microsoft.entra,microsoft.graph
```

<br>


## 4. Configure VS Code

### Start VS Code, ignore GitHub Copilot

<img src="./media/Install_and_configure_VSCode_40.png" alt="Ignore GitHub Copilot" width="500">


### Create keyboard shortcut

`Ctrl-K Ctl-S` -> `Run Selected Text in Active Terminal` -> F8

<img src="./media/Install_and_configure_VSCode_50.png" alt="Keyboard shortcut" width="500">


### Useful user settings

`Ctrl-Shift-P` -> `Open User Settings (JSON)`

```jsonc
{
    "editor.minimap.enabled": false,
    "editor.occurrencesHighlight": "off",
    "editor.selectionHighlight": false,
    "editor.inlineSuggest.enabled": true,
    "explorer.openEditors.visible": 1,
    "powershell.codeFolding.enable": true,
    "powershell.codeFolding.showLastLine": false,
    "powershell.codeFormatting.useCorrectCasing": true,
    "powershell.integratedConsole.showOnStartup": false,
    "powershell.promptToUpdatePowerShell": false,
    "powershell.scriptAnalysis.enable": false,
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.cursorStyle": "block",
    "terminal.integrated.cursorWidth": 2,
    "terminal.integrated.defaultProfile.windows": "PowerShell",
    "terminal.integrated.shellIntegration.enabled": true,
    "window.commandCenter": false,
    "window.zoomLevel": 1,
    "workbench.colorCustomizations": {
        "editor.findMatchBackground": "#E8A23580",
        "editor.findMatchBorderColor": "#E8A235",
        "editor.findMatchHighlightBackground": "#E8A23540",
        "editor.findMatchHighlightBorderColor": "#E8A23580"
    },
    "workbench.startupEditor": "none",
    "workbench.tree.indent": 20
}
```

### Explore some build in shortcuts

|   |   |
| - | - |
| Command palette   | Ctrl-Shift-P  |
| IntelliSense      | Ctrl-Space    |
| Toogle terminal   | Ctrl-J        |
| Clear terminal    | Ctrl-L        |
| Move line up/down | Alt-↓↑        |
| Copy line up/down | Alt-Shift-↓↑  |
| Delete line       | Ctrl-Shift-K  |
| Search            | Ctrl-F        |
| Search & replace  | Ctrl-H        |

<br>

<br>

## 5. Happy VS Code!