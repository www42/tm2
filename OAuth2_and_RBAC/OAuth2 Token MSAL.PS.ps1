# Get Token mit MSAL.PS
# -------------------------------------

# Vorbemerkung: 
#   Das braucht man eigentlich nicht. Ein 'Connect-MgGraph' holt sich selbst ein Token auch ohne MSAL.PS.
#   Allerdings sieht man das Token (die Token - es gibt Access Token und Identity Token) nicht direkt.
#   Das Schöne an MSAL.PS ist, dass es die Token direkt in die Hand bekommt, um sie zu analysieren z.B. in https://jwt.ms
#   Man kann die von MSAL.PS gelieferten Token auch richtig nutzen: Connect-MgGraph -AccessToken $token 
#   Das Module MSAL.PS ist zwar von Microsoft Mitarbeiterm geschrieben, wird aber nicht von Microsoft supported.

Get-Module -ListAvailable -Name MSAL.PS

# Client App ist 'Microsoft Graph Command Line Tools'
$clientId = "14d82eec-204b-4c2f-b7e8-296a70dab67e"      # das ist die AppId
$tenantId = "819ebf55-0973-4703-b006-581a48f25961"      # az.training

# Gewünschte Permissions im Claim 'scp'
$scopes = @("https://graph.microsoft.com/User.Read")


# Token anfordern interaktiv - Beispiel als User 'Anton Zeilinger'
$token = Get-MsalToken -ClientId $clientId -TenantId $tenantId -Scopes $scopes -Interactive
$token

# Token analysieren
$token.AccessToken | clip  # --> https://jwt.ms
$token.IdToken | clip   # --> https://jwt.ms

# Token verwenden
Connect-MgGraph -AccessToken (ConvertTo-SecureString -String $token.AccessToken -AsPlainText)
Get-MgContext
Get-MgContext | % Scopes

# Test Scopes - Was darf Anton Zeilinger mit dem Scope User.Read?
Get-MgUser -All                                                 # --> NO  User.Read reicht nicht
Get-MgUser    -UserId 'eb70948f-0480-4163-9f9e-4a8da8cadefa'    # --> YES sich selbst anzeigen geht
Update-MgUser -UserId 'eb70948f-0480-4163-9f9e-4a8da8cadefa' -BusinessPhones '0817'  # --> NO  ändern geht nicht

Disconnect-MgGraph




# Anmerkungen
# ==============

# Token lokal decodieren
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

Decode-JwtToken $token.AccessToken | fl *
Decode-JwtToken $token.AccessToken | % Payload

Decode-JwtToken $token.IdToken | fl *
Decode-JwtToken $token.IdToken | % Payload


# Audience: Identifies the intended recipient of the token. In id_tokens, the audience is your app's Application ID
# Scope:    The set of scopes exposed by your application for which the client application has requested (and received) consent
$scopes = @("https://graph.microsoft.com/User.Read")
#           |           aud             |   scp   |
#           |         audience          |  scope  |

# Audience/Scope für Azure ARM
$scopes = @("https://management.core.windows.net//user_impersonation")
#                                         double slash
