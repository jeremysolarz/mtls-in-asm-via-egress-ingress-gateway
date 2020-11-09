../set-project-and-cluster-client.sh

./clean-up.sh

# folder where certificates are stored created by mtls-go-example
CERTS_ROOT="../../httpbin-certs"

# url of the external service
SERVICE_URL="httpbin-mutual-tls.jeremysolarz.app"

kubectl apply -f service-entry.yaml

kubectl create -n istio-system secret tls httpbin-client-certs \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem

kubectl create -n istio-system secret generic httpbin-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl -n istio-system patch --type=json deploy istio-egressgateway -p "$(cat gateway-patch.json)"

sleep 15
kubectl exec -it -n istio-system $(kubectl -n istio-system get pods -l istio=egressgateway -o jsonpath='{.items[0].metadata.name}') \
  -- ls -al /etc/istio/httpbin-client-certs /etc/istio/httpbin-ca-certs

# setup routing for the mysql service inside the mesh
kubectl apply -f gateway-destinationrule-to-egressgateway.yaml

# now activate the virtualservice that does the routing from the pod to the egress-gateway and from the
# egress gateway outside, additionally tell the egress gateway to use the certificates mounted before for
# the outbound traffic (via the destination rule)
kubectl apply -f virtualservice-destinationrule-from-egressgateway.yaml