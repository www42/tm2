
$subscriptionId = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'
$subscriptionId = '4072ef16-4983-440e-af57-d3afa9a6ea96'

# Achtung Druckfehler 'SubscriptionPolices' ohne i
Get-AzSubscription -SubscriptionId $subscriptionId | % ExtendedProperties | % SubscriptionPolices | ConvertFrom-Json | % quotaId