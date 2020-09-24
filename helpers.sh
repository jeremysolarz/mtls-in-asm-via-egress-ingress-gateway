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
.
# curl https://httpbin-mutual-tls.jeremysolarz.app/status/418 \
#  --cacert 2_intermediate/certs/ca-chain.cert.pem \
#  --cert 4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem \
#  --key 4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem
#
# curl -v http://httpbin-mutual-tls.jeremysolarz.app/status/418
#
# curl -v httpbin-external/status/418


# echo hello | openssl s_client -connect httpbin-mutual-tls.jeremysolarz.app:3306
# mysql -h httpbin-mutual-tls.jeremysolarz.app -pGoogle1!

export CERTS_ROOT="../../httpbin-certs"
curl https://httpbin-mutual-tls.jeremysolarz.app:16443 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem

export CERTS_ROOT="../../mysql-certs"
curl https://mysql-mutual-tls.jeremysolarz.app:13306 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/mysql-mutual-tls.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/mysql-mutual-tls.jeremysolarz.app.key.pem

export CERTS_ROOT="../../mysql-eks-certs"
curl https://mysql-mutual-tls-eks.jeremysolarz.app:13306 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/mysql-mutual-tls-eks.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/mysql-mutual-tls-eks.jeremysolarz.app.key.pem

# mysql -hmysql-mutual-tls.jeremysolarz.app -pyougottoknowme

## server
# create database remote_connection;
# use remote_connection;
# create table hello_world(text varchar(255));
# insert into hello_world(text) values('hello terasky');
# insert into hello_world(text) values('hello mambu');

## client
## use remote_connection; select * from hello_world;