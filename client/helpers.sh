export CERTS_ROOT="../../httpbin-certs"
export SERVICE_URL="httpbin-mutual-tls.jeremysolarz.app"
export MYSQL_SECURE_PORT="16443"

# get logs for istio-egressgateway
kubectl logs -n istio-system -l app=istio-egressgateway -f

# get logs for istio-prox running inside sleep
kubectl logs -l app=sleep -c istio-proxy -f

# attach to sleep pod
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep -- /bin/sh

# attach to istio-egressgateway
kubectl exec -it -n istio-system "$(kubectl get pod -n istio-system -l app=istio-egressgateway -o jsonpath={.items..metadata.name})" \
  -- /bin/bash

# curl with certs from istio-egressgateway
kubectl exec -it -n istio-system "$(kubectl get pod -n istio-system -l app=istio-egressgateway -o jsonpath={.items..metadata.name})" \
 -- curl -v \
 --cacert /etc/istio/httpbin-ca-certs/ca-chain.cert.pem \
 --cert /etc/istio/httpbin-client-certs/tls.crt \
 --key /etc/istio/httpbin-client-certs/tls.key \
 https://$SERVICE_URL/status/418

# curl without certificat
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep \
  -- curl -v http://$SERVICE_URL/status/418

# curl via alias
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep \
  -- curl -v httpbin-external/status/418

# curl from local with the certificates
curl https://$SERVICE_URL/status/418 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/$SERVICE_URL.cert.pem \
  --key $CERTS_ROOT/4_client/private/$SERVICE_URL.key.pem

curl https://$SERVICE_URL:$MYSQL_SECURE_PORT \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/$SERVICE_URL.cert.pem \
  --key $CERTS_ROOT/4_client/private/$SERVICE_URL.key.pem