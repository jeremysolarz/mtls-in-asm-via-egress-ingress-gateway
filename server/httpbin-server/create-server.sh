export CERTS_ROOT="../../httpbin-certs"

gcloud config set project jsolarz-sandbox
gcloud container clusters get-credentials anthos-on-gcp --zone us-central1-c --project jsolarz-sandbox

kubectl delete --ignore-not-found=true gateway mygateway
kubectl delete --ignore-not-found=true virtualservice httpbin
kubectl delete --ignore-not-found=true -n istio-system secret httpbin-credential httpbin-credential-cacert

kubectl create -n istio-system secret generic httpbin-credential \
--from-file=tls.key=$CERTS_ROOT/3_application/private/httpbin-mutual-tls.jeremysolarz.app.key.pem \
--from-file=tls.crt=$CERTS_ROOT/3_application/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem \
--from-file=ca.crt=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl create -n istio-system secret generic httpbin-credential-cacert \
--from-file=cacert=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl apply -f httpbin-gw-mutual.yaml
kubectl apply -f httpbin-vs.yaml

sleep 5
# jsolarz-sanbox
curl -v -HHost:httpbin-mutual-tls.jeremysolarz.app --resolve \
  "httpbin-mutual-tls.jeremysolarz.app:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem \
  "https://httpbin-mutual-tls.jeremysolarz.app:$SECURE_INGRESS_PORT/status/418"

# external
curl -v --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem \
  "https://httpbin-mutual-tls.jeremysolarz.app/status/418"