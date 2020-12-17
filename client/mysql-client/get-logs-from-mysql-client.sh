DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../../env-vars

$DIR/../set-project-and-cluster-client.sh

kubectl logs -l run=mysql-client -c istio-proxy -f