####
CERTS_ROOT="../../httpbin-certs"

gcloud config set project vch-anthos-demo
gcloud container clusters get-credentials anthos-gcp --region europe-west4 --project vch-anthos-demo

./clean-up.sh

kubectl apply -f httpbin-external.yaml

kubectl apply -f se-vs.yaml

kubectl create secret tls httpbin-client-certs --key $CERTS_ROOT/4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem --cert $CERTS_ROOT/4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem
kubectl create secret generic httpbin-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl apply -f sleep.yaml

sleep 2
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
echo $SOURCE_POD

sleep 4
kubectl exec -it $SOURCE_POD -c sleep -- curl -v --cacert /etc/httpbin-ca-certs/ca-chain.cert.pem --cert /etc/httpbin-client-certs/tls.crt --key /etc/httpbin-client-certs/tls.key https://httpbin-mutual-tls.jeremysolarz.app/status/418
# sleep 2
# kubectl exec -it $(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl -k https://httpbin-mutual-tls.jeremysolarz.app

# now use the proxy

kubectl create -n istio-system secret tls httpbin-client-certs \
  --key $CERTS_ROOT/4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem \
  --cert $CERTS_ROOT/4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem

kubectl create -n istio-system secret generic httpbin-ca-certs --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl -n istio-system patch --type=json deploy istio-egressgateway -p "$(cat gateway-patch.json)"

sleep 15
kubectl exec -it -n istio-system $(kubectl -n istio-system get pods -l istio=egressgateway -o jsonpath='{.items[0].metadata.name}') -- ls -al /etc/istio/httpbin-client-certs /etc/istio/httpbin-ca-certs

kubectl apply -f gw-dr.yaml

kubectl apply -f vs-dr.yaml

kubectl exec -it $SOURCE_POD -c sleep -- curl -v http://httpbin-mutual-tls.jeremysolarz.app/status/418

# curl  -v httpbin-mutual-tls.jeremysolarz.app/status/418

# curl  -v --resolve thisisatest:443:1.1.1.1 thisisatest/status/418