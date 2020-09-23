# reinstall istio
istioctl install \
  -f asm/cluster/istio-operator.yaml \
  -f ../istio-features.yaml

# get logs for istio-egressgateway
kubectl logs -n istio-system -l app=istio-egressgateway -f
# get logs for istio-prox running inside sleep
kubectl logs -l app=sleep -c istio-proxy -f

# attach to sleep pod
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep -- /bin/sh

# attach to istio-egressgateway
kubectl exec -it -n istio-system "$(kubectl get pod -n istio-system -l app=istio-egressgateway -o jsonpath={.items..metadata.name})" -- /bin/bash

# curl with certs from istio-gateway
kubectl exec -it -n istio-system "$(kubectl get pod -n istio-system -l app=istio-egressgateway -o jsonpath={.items..metadata.name})" -- curl -v \
 --cacert /etc/istio/nginx-ca-certs/example.com.crt \
 --cert /etc/istio/nginx-client-certs/tls.crt \
 --key /etc/istio/nginx-client-certs/tls.key \
 https://httpbin-mutual-tls.jeremysolarz.app/status/418

curl https://httpbin-mutual-tls.jeremysolarz.app/status/418 \
  --cacert 2_intermediate/certs/ca-chain.cert.pem \
  --cert 4_client/certs/nginx.example.com.cert.pem \
  --key 4_client/private/nginx.example.com.key.pem

curl -v http://httpbin-mutual-tls.jeremysolarz.app/status/418

curl -v httpbin-external/status/418


echo hello | openssl s_client -connect httpbin-mutual-tls.jeremysolarz.app:3306

mysql -h httpbin-mutual-tls.jeremysolarz.app -pGoogle1!