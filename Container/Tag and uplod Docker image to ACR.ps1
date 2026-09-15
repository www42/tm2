# Tag a local Docker image and upload it to Azure Container Registry ACR

# Docker Desktop running?
docker info

# Login Container Registry
$acrName = 'timmy'
$loginServer = (az acr show --name $acrName --query "loginServer" --output tsv)
$adminUser = (az acr credential show --name $acrName --query "username" --output tsv)
$adminPassword = (az acr credential show --name $acrName --query "passwords[0].value" --output tsv)
az acr login --name $acrName --username $adminUser --password $adminPassword

# Logoff by 'docker logout'
#docker logout $loginServer

# Tag and upload Docker image
docker image ls twingate/connector:1
docker image tag twingate/connector:1 $loginServer/connector:1
docker image ls 
docker image push $loginServer/connector:1

az acr repository list --name $acrName --output table

# Remove tagged image locally
docker image rm $loginServer/connector:1