$rgName= 'rg-kubernetes'

az aks list --resource-group $rgName --query "[].{name:name,kubernetesVersion:kubernetesVersion,fqdn:fqdn}" -o table
$clusterName = 'kube1'

az aks get-credentials --resource-group $rgName --name $clusterName

kubectl config get-clusters
kubectl config get-contexts 
kubectl config current-context

kubectl get nodes
kubectl get pods
kubectl get pods --all-namespaces

# Super Mario
# -----------------
dir Kubernetes/supermario.yaml
kubectl apply -f 'Kubernetes/supermario.yaml'

kubectl get pods
kubectl get service

kubectl delete -f 'Kubernetes/supermario.yaml'

# Azure Vote --> Does not work
# ----------------------------
dir Kubernetes/azure-vote.yaml
kubectl apply  -f 'Kubernetes/azure-vote.yaml'
kubectl delete -f 'Kubernetes/azure-vote.yaml'