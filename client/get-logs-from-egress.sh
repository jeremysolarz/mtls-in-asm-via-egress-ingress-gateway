DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../env-vars

$DIR/./set-project-and-cluster-client.sh

kubectl logs -n istio-system -l app=istio-egressgateway -f