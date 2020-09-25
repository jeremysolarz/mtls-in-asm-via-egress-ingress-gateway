
gcloud config set project jsolarz-sandbox
gcloud container clusters get-credentials anthos-on-gcp --zone us-central1-c --project jsolarz-sandbox

./clean-up.sh

# folder where certificates are stored created by mtls-go-example
CERTS_ROOT="../../httpbin-certs"

# url of the external service
SERVICE_URL="httpbin-mutual-tls.jeremysolarz.app"


kubectl create -n istio-system secret generic httpbin-credential \
--from-file=tls.key=$CERTS_ROOT/3_application/private/${SERVICE_URL}.key.pem \
--from-file=tls.crt=$CERTS_ROOT/3_application/certs/${SERVICE_URL}.cert.pem \
--from-file=ca.crt=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl create -n istio-system secret generic httpbin-credential-cacert \
--from-file=cacert=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl apply -f httpbin-gw-mutual.yaml
kubectl apply -f httpbin-vs.yaml

sleep 5
# jsolarz-sanbox
curl -v -HHost:${SERVICE_URL} --resolve \
  "${SERVICE_URL}:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  "https://${SERVICE_URL}:$SECURE_INGRESS_PORT/status/418"

# external
curl -v --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  "https://${SERVICE_URL}/status/418"