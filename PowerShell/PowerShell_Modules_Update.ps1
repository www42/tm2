# Windows: Update in Terminal as administrator!
# MacOS: sudo pwsh
# ----------------------------------------------------------------------------------------------------------
# Install-Module -Name xv -Force -Scope AllUsers   --> local C:
# Install-Module -Name xv -Force                   --> OneDrive


# --- Azure (5.1 and 7) ---------------------------------
Get-Module     -Name Az -ListAvailable
Find-Module    -Name Az -Repository PSGallery
function Remove-OldAzModule {
    #   a) Uninstall all dependent modules Az.*
    #   b) Uninstall module Az
    #
    #   See https://smarttechways.com/2021/05/18/install-and-uninstall-az-module-in-powershell-for-azure/
    
    #   WindowsPowerShell 5 differs from PowerShell 7:
    #   Get-Module -Name Az   # does not work
    
    switch ($PSVersionTable.PSVersion.Major) {
        '5' {
            $AzVersions = Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\Az\' 
            $AzModules = ($AzVersions | 
            ForEach-Object {
                Import-Clixml -Path (Join-Path -Path $_.FullName -ChildPath PSGetModuleInfo.xml)
            }).Dependencies.Name | Sort-Object -Unique
        }
        '7' {
            $AzVersions = Get-Module -Name Az -ListAvailable
            $AzModules = ($AzVersions | 
            ForEach-Object {
                Import-Clixml -Path (Join-Path -Path $_.ModuleBase -ChildPath PSGetModuleInfo.xml)
            }).Dependencies.Name | Sort-Object -Unique
        }
    }
    
    #   a) Uninstall all dependent modules Az.*
    $AzModules | ForEach-Object {
        Remove-Module -Name $_ -ErrorAction SilentlyContinue
        Write-Output "Uninstalling module $_ ..."
        Uninstall-Module -Name $_ -AllVersions
    }
    
    #    b) Uninstall module Az
    Remove-Module -Name Az -ErrorAction SilentlyContinue
    Write-Output "Uninstalling module Az"
    Uninstall-Module -Name Az -AllVersions
}
Remove-OldAzModule
Install-Module -Name Az -Repository PSGallery -Scope AllUsers -Force


# --- AzureAD (5.1 only) ---------------------------------
Get-Module       -Name AzureAD -ListAvailable
Find-Module      -Name AzureAD -Repository PSGallery
Install-Module   -Name AzureAD -Repository PSGallery -Scope AllUsers -Force
Uninstall-Module -Name AzureAD -RequiredVersion <old version>


# --- MSOnline (5.1 only) ---------------------------------
Get-Module       -Name MSOnline -ListAvailable
Find-Module      -Name MSOnline -Repository PSGallery
Install-Module   -Name MSOnline -Repository PSGallery -Scope AllUsers -Force
Uninstall-Module -Name MSOnline -RequiredVersion <old version>


# --- Exchange Online (5.1 and 7) -------------------------
Get-Module       -Name ExchangeOnlineManagement -ListAvailable 
Find-Module      -Name ExchangeOnlineManagement -Repository PSGallery
Find-Module      -Name ExchangeOnlineManagement -Repository PSGallery -AllowPrerelease  # Powershell 7
Install-Module   -Name ExchangeOnlineManagement -Repository PSGallery -Scope AllUsers -Force
Uninstall-Module -Name ExchangeOnlineManagement -RequiredVersion <old version>


# --- Microsoft Graph (5.1 and 7) -------------------------
Get-Module     -Name Microsoft.Graph -ListAvailable
Find-Module    -Name Microsoft.Graph -Repository PSGallery
function Remove-OldGraphModule {
    # Remove all Graph modules except Microsoft.Graph.Authentication
    $Modules = Get-Module Microsoft.Graph* -ListAvailable | Where {$_.Name -ne "Microsoft.Graph.Authentication"} | Select-Object Name -Unique
    Foreach ($Module in $Modules) {
        $ModuleName = $Module.Name
        $Versions = Get-Module $ModuleName -ListAvailable
        Foreach ($Version in $Versions) {
            $ModuleVersion = $Version.Version
            Write-Host "Uninstall-Module $ModuleName $ModuleVersion"
            Uninstall-Module $ModuleName -RequiredVersion $ModuleVersion -Force -ErrorAction SilentlyContinue
        }
    }
    # Remove Microsoft.Graph.Authentication
    $ModuleName = "Microsoft.Graph.Authentication"
    $Versions = Get-Module $ModuleName -ListAvailable
    Foreach ($Version in $Versions) {
        $ModuleVersion = $Version.Version
        Write-Host "Uninstall-Module $ModuleName $ModuleVersion"
        Uninstall-Module $ModuleName -RequiredVersion $ModuleVersion -Force -ErrorAction SilentlyContinue
    }
}
Remove-OldGraphModule
Install-Module -Name Microsoft.Graph -Repository PSGallery -Scope AllUsers -Force



# New Entra Module
#     https://www.youtube.com/watch?v=YOgpAkshmYI
#
Get-Module     -Name Microsoft.Graph.Entra* -ListAvailable
# Update-Module  -- Werden alte Versionen entfernt?

# --- Microsoft Graph Entra (/v1 Endpoint) ----------------
Get-Module     -Name Microsoft.Graph.Entra -ListAvailable
Find-Module    -Name Microsoft.Graph.Entra -Repository PSGallery -AllowPrerelease
Install-Module -Name Microsoft.Graph.Entra -Repository PSGallery -Scope AllUsers -AllowPrerelease -Force

# --- Microsoft Graph Entra Beta (/beta Endpoint)  --------
Get-Module     -Name Microsoft.Graph.Entra.Beta -ListAvailable
Find-Module    -Name Microsoft.Graph.Entra.Beta -Repository PSGallery -AllowPrerelease
Install-Module -Name Microsoft.Graph.Entra.Beta -Repository PSGallery -Scope AllUsers -AllowPrerelease -Force -AllowClobber




# --- MSAL.PS (7) -----------------------------------------
Get-Module     -Name MSAL.PS -ListAvailable
Find-Module    -Name MSAL.PS -Repository PSGallery
Install-Module -Name MSAL.PS -Repository PSGallery -Scope AllUsers -Force
Update-Module  -Name MSAL.PS -Force


# --- Entra Exporter --------------------------------------
Get-Module     -Name EntraExporter -ListAvailable
Find-Module    -Name EntraExporter -Repository PSGallery
Install-Module -Name EntraExporter -Repository PSGallery -Scope AllUsers -Force
