using namespace System.Net

param($Request, $TriggerMetadata)

Write-Host "GetManagedDisks function processing request."

try {
    # Authentifizierung via System-assigned Managed Identity der Function App.
    # Lokal (ohne Identity) musst du dich vorher einmalig mit
    # Connect-AzAccount anmelden; dann greift der bestehende Az-Kontext.
    if ($env:MSI_SECRET -or $env:IDENTITY_ENDPOINT) {
        Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
    }

    # Subscription explizit setzen, falls die Identity Zugriff auf mehrere hat
    $subscriptionId = $env:TARGET_SUBSCRIPTION_ID
    if ($subscriptionId) {
        Set-AzContext -Subscription $subscriptionId -ErrorAction Stop | Out-Null
    }

    # Managed Disks abfragen und auf relevante Felder reduzieren
    $disks = Get-AzDisk | Select-Object `
        Name,
        ResourceGroupName,
        Location,
        @{ Name = 'SizeGB';    Expression = { $_.DiskSizeGB } },
        @{ Name = 'Sku';       Expression = { $_.Sku.Name } },
        @{ Name = 'State';     Expression = { $_.DiskState } },
        @{ Name = 'ManagedBy'; Expression = { $_.ManagedBy } },
        Id

    # -AsArray sorgt dafür, dass auch bei genau einer Disk ein Array zurückkommt
    $body = $disks | ConvertTo-Json -Depth 5 -AsArray

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Headers    = @{ 'Content-Type' = 'application/json' }
        Body       = $body
    })
}
catch {
    Write-Error "Error retrieving managed disks: $_"

    $errorBody = @{
        error   = $_.Exception.Message
        details = $_.ScriptStackTrace
    } | ConvertTo-Json -Depth 3

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Headers    = @{ 'Content-Type' = 'application/json' }
        Body       = $errorBody
    })
}