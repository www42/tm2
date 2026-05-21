# Deploy Supermario game on Kubernetes
# -------------------------------------

# Resource groups
az group list --query "sort_by([].{Name:name,Region:location}, &Name)" --output table
$rgName= 'rg-kubernetes'


# Container registries
az acr list --query "[].{name:name,location:location,resourceGroup:resourceGroup,loginServer:loginServer,adminUserEnabled:adminUserEnabled}" --output table
$acrName = 'whalewatch'


# Container images
az acr repository list --name $acrName
az acr repository show --name $acrName --repository supermario


# Kubernetes clusters
az aks list --resource-group $rgName --query "[].{name:name,kubernetesVersion:kubernetesVersion,fqdn:fqdn}" --output table
$clusterName = 'kube1'


# Credentials
az aks get-credentials --resource-group $rgName --name $clusterName --overwrite-existing


# --> kubectl
kubectl config get-contexts 

kubectl get nodes
kubectl get pods
kubectl get pods --all-namespaces


# Manifest
dir Kubernetes/supermario.yaml
code Kubernetes/supermario.yaml


# Deployment
kubectl apply -f 'Kubernetes/supermario.yaml'

kubectl get pods
kubectl get service


# Kill Supermario
kubectl delete -f 'Kubernetes/supermario.yaml'
