./set-project-and-cluster-client.sh

kubectl logs -l app=sleep -c istio-proxy -f