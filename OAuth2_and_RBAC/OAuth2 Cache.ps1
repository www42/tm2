# OAuth2 Token Cache
# -------------------------------------

# Es gibt wohl verschiedene Ordner für das Caching:
#   Option 1: Im USERPROFILE
Test-Path "$env:USERPROFILE\.graph"             # --> false

#   Option 2: Im LOCALAPPDATA
Test-Path "$env:LOCALAPPDATA\.IdentityService"  # --> true

#   Option 3: Neuere Versionen nutzen manchmal:
Test-Path "$env:LOCALAPPDATA\Microsoft\Graph"   # --> false

#   Option 4: MSAL Cache Location
Test-Path "$env:LOCALAPPDATA\.msal"             # --> false

# Also bei mir gibt es nur Option 2
$tokenCache = "$env:LOCALAPPDATA\.IdentityService"
Get-ChildItem $tokenCache -Force

cat $tokenCache/mg.msal.cache.cae
cat $tokenCache/mg.msal.cache.nocae
cat $tokenCache/msal.cache.cae
# Alles nicht lesbar (verschlüsselt?)
# cae = Continuous Access Evaluation (Security Feature)
# Disconnect-MgGraph löscht nicht den Cache

# Wie löscht man den Cache? Ganzen Ordner löschen?
# Das cmdlet `Clear-MsalTokenCache` aus MSAL.PS **löscht nicht** / **manipuliert nicht** die drei o.g. Dateien
dir "$env:LOCALAPPDATA\.IdentityService\*.cache.*" 
