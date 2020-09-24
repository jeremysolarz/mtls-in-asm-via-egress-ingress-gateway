####
CERTS_ROOT="../../mysql-certs"

gcloud config set project vch-anthos-demo
gcloud container clusters get-credentials anthos-gcp --region europe-west4 --project vch-anthos-demo

# ./clean-up.sh

kubectl create -n istio-system secret tls mysql-client-certs \
  --key $CERTS_ROOT/4_client/private/mysql-mutual-tls.jeremysolarz.app.key.pem \
  --cert $CERTS_ROOT/4_client/certs/mysql-mutual-tls.jeremysolarz.app.cert.pem

kubectl create -n istio-system secret generic mysql-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl -n istio-system patch --type=json deploy istio-egressgateway -p "$(cat gateway-patch.json)"

sleep 15
kubectl exec -it -n istio-system $(kubectl -n istio-system get pods -l istio=egressgateway -o jsonpath='{.items[0].metadata.name}') -- ls -al /etc/istio/mysql-client-certs /etc/istio/mysql-ca-certs

kubectl apply -f se-mysql.yaml