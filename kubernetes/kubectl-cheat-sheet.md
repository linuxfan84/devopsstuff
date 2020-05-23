# kubectl cheat sheet

View all objects in k8s cluster:  
  
kgall  
Obtain all logs from all pods in deployment:  
  
for p in $\(kubectl get pods --namespace=kube-system -l k8s-app=kube-dns -o name\); do kubectl logs --namespace=kube-system $p; done



