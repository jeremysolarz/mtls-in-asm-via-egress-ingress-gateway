DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/../set-project-and-cluster-client.sh

# todo cleanup cleanup.sh :D
kubectl delete --ignore-not-found=true secret mysql-client-certs mysql-ca-certs
kubectl delete --ignore-not-found=true secret mysql-client-certs mysql-ca-certs -n istio-system

kubectl delete -f gateway-destinationrule-to-egressgateway.yaml
kubectl delete -f virtualservice-destinationrule-from-egressgateway.yaml
kubectl delete -f service-entry.yaml

# reset ASM
#istioctl install \
#  -f ../../../istio-1.6.8-asm.9/asm/cluster/istio-operator.yaml \
#-f ../features.yaml
#
#kubectl get deploy -n istio-system
#kubectl get ns