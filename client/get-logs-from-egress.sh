. ../env-vars

./set-project-and-cluster-client.sh

kubectl logs -n istio-system -l app=istio-egressgateway -f