# Training fa Subscription
$subscriptionId = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'

# Pay-As-You-Go Dev/Test
$subscriptionId = '4072ef16-4983-440e-af57-d3afa9a6ea96'

# Pay-As-You-Go 2
$subscriptionId = 'e119ff07-d872-4485-b81b-31a359a01d17'

Get-AzSubscription

# Achtung Druckfehler 'SubscriptionPolices' ohne i
Get-AzSubscription -SubscriptionId $subscriptionId | % ExtendedProperties | % SubscriptionPolices | ConvertFrom-Json | % quotaId