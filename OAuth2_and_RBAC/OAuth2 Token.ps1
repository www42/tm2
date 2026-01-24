# Get Token
# -------------------------------------

# Das Modul MSAL.PS

$clientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e"  # Microsoft Graph Command Line Tools
$tenantId = "819ebf55-0973-4703-b006-581a48f25961"
$scopes = @("https://graph.microsoft.com/User.Read.All")
$scopes = @("https://graph.microsoft.com/User.Read")

$token = Get-MsalToken -ClientId $clientId -TenantId $tenantId -Scopes $scopes -Interactive
$token

$token.AccessToken | clip  # --> https://jwt.ms
Decode-JwtToken $token.AccessToken | fl *
Decode-JwtToken $token.AccessToken | % Payload

$token.IdToken | clip   # --> https://jwt.ms
Decode-JwtToken $token.IdToken | fl *
Decode-JwtToken $token.IdToken | % Payload


function Decode-JwtToken {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Token
    )
    
    # JWT besteht aus 3 Teilen: Header.Payload.Signature
    $parts = $Token.Split('.')
    
    if ($parts.Count -ne 3) {
        throw "Ungültiges JWT Token Format"
    }
    
    # Decode Header
    $headerBytes = [Convert]::FromBase64String(($parts[0].Replace('-', '+').Replace('_', '/').PadRight($parts[0].Length + (4 - $parts[0].Length % 4) % 4, '=')))
    $header = [System.Text.Encoding]::UTF8.GetString($headerBytes) | ConvertFrom-Json
    
    # Decode Payload
    $payloadBytes = [Convert]::FromBase64String(($parts[1].Replace('-', '+').Replace('_', '/').PadRight($parts[1].Length + (4 - $parts[1].Length % 4) % 4, '=')))
    $payload = [System.Text.Encoding]::UTF8.GetString($payloadBytes) | ConvertFrom-Json
    
    # Signature (nicht dekodiert, nur Base64)
    $signature = $parts[2]
    
    [PSCustomObject]@{
        Header = $header
        Payload = $payload
        Signature = $signature
    }
}