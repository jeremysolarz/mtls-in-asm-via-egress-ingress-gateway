gcloud config set project jsolarz-sandbox
gcloud container clusters get-credentials anthos-on-gcp --zone us-central1-c --project jsolarz-sandbox

# simple test
kubectl delete --ignore-not-found=true gateway mygateway
kubectl delete --ignore-not-found=true virtualservice httpbin
kubectl delete --ignore-not-found=true -n istio-system secret httpbin-credential

kubectl create -n istio-system secret tls httpbin-credential \
  --key=../3_application/private/httpbin-mutual-tls.jeremysolarz.app.key.pem \
  --cert=../3_application/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem


kubectl apply -f httpbin-gw-simple.yaml
kubectl apply -f httpbin-vs.yaml

sleep 5
curl -v -HHost:httpbin-mutual-tls.jeremysolarz.app --resolve \
  "httpbin-mutual-tls.jeremysolarz.app:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
  --cacert ../2_intermediate/certs/ca-chain.cert.pem \
  "https://httpbin-mutual-tls.jeremysolarz.app:$SECURE_INGRESS_PORT/status/418"

