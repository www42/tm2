# Alle 'Foundry Projects' finden

# --> Suche über Azure Resource Graph

# Anmerkung:
#   Die Suche liefert immer *eine* Liste mit den Projects, nicht die Projects einzeln. 
#   Um die Projects zu erhalten muss die Liste enumeriert werden
#       Search-AzGraph ... | ForEach-Object {$_} |
#   oder
#       (Search-AzGraph ...) |

Search-AzGraph -First 1000 -Query `
@"
    resources
    | where type =~ 'microsoft.cognitiveservices/accounts/projects'
    | extend FoundryResource = tostring(split(name, '/')[0]),
             Project         = tostring(split(name, '/')[1])
    | project Project, FoundryResource, ResourceGroup = resourceGroup, Location = location, subscriptionId
    | order by FoundryResource asc, Project asc
"@ | ForEach-Object {$_} | Sort-Object Project | Format-Table