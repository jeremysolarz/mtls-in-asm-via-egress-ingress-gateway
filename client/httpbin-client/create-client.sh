####

gcloud config set project vch-anthos-demo
gcloud container clusters get-credentials anthos-gcp --region europe-west4 --project vch-anthos-demo

./clean-up.sh

# folder where certificates are stored created by mtls-go-example
CERTS_ROOT="../../httpbin-certs"

# url of the external service
SERVICE_URL="httpbin-mutual-tls.jeremysolarz.app"

kubectl apply -f httpbin-external.yaml

# add the service entry to the istio registry
kubectl apply -f service-entry.yaml

kubectl create secret tls httpbin-client-certs --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem
kubectl create secret generic httpbin-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl apply -f sleep.yaml

sleep 2
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
echo $SOURCE_POD

sleep 4
kubectl exec -it $SOURCE_POD -c sleep -- curl -v \
  --cacert /etc/httpbin-ca-certs/ca-chain.cert.pem \
  --cert /etc/httpbin-client-certs/tls.crt \
  --key /etc/httpbin-client-certs/tls.key https://${SERVICE_URL}/status/418
# sleep 2
# kubectl exec -it $(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl -k https://${SERVICE_URL}

# create the secrets that hold the certificates for the egress proxy
kubectl create -n istio-system secret tls httpbin-client-certs \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem

kubectl create -n istio-system secret generic httpbin-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

# patch the egress gateway to mount the secret (aka certificates)
kubectl -n istio-system patch --type=json deploy istio-egressgateway -p "$(cat gateway-patch.json)"

sleep 15
kubectl exec -it -n istio-system $(kubectl -n istio-system get pods -l istio=egressgateway -o jsonpath='{.items[0].metadata.name}') -- ls -al /etc/istio/httpbin-client-certs /etc/istio/httpbin-ca-certs

# patch the egress gateway to mount the secret (aka certificates)
kubectl apply -f gateway-destinationrule-to-egressgateway.yaml

# now activate the virtualservice that does the routing from the pod to the egress-gateway and from the
# egress gateway outside, additionally tell the egress gateway to use the certificates mounted before for
# the outbound traffic (via the destination rule)
kubectl apply -f virtualservice-destinationrule-from-egressgateway.yaml

kubectl exec -it $SOURCE_POD -c sleep -- curl -v http://${SERVICE_URL}/status/418

# curl  -v ${SERVICE_URL}/status/418

# curl  -v --resolve thisisatest:443:1.1.1.1 thisisatest/status/418