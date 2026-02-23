dir 'Kubernetes/supermario.yaml'

kubectl config current-context

kubectl apply -f 'Kubernetes/supermario.yaml'

kubectl get pods
kubectl get service


kubectl delete -f 'Kubernetes/supermario.yaml'