DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../../server/set-project-and-cluster-server.sh

# !!! WARNING - DO NOT MOVE !!!
# get Ingress IP from server side
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

$DIR/../set-project-and-cluster-client.sh

$DIR/./clean-up.sh

# folder where certificates are stored created by mtls-go-example
CERTS_ROOT="$DIR/../../certs"

# url of the external service
SERVICE_URL="$INGRESS_HOST.nip.io"
# SERVICE_URL="35.239.250.140.nip.io"


kubectl apply -f service-entry.yaml

kubectl create -n istio-system secret tls mysql-client-certs \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem

kubectl create -n istio-system secret generic mysql-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

# kubectl -n istio-system patch --type=json deploy istio-egressgateway -p "$(cat gateway-patch.json)"

sleep 15
kubectl exec -it -n istio-system $(kubectl -n istio-system get pods -l istio=egressgateway -o jsonpath='{.items[0].metadata.name}') \
  -- ls -al /etc/istio/mysql-client-certs /etc/istio/mysql-ca-certs

# setup routing for the mysql service inside the mesh
kubectl apply -f gateway-destinationrule-to-egressgateway.yaml

# now activate the virtualservice that does the routing from the pod to the egress-gateway and from the
# egress gateway outside, additionally tell the egress gateway to use the certificates mounted before for
# the outbound traffic (via the destination rule)
kubectl apply -f virtualservice-destinationrule-from-egressgateway.yaml