export CERTS_ROOT="../../mysql-certs"

kubectl delete --ignore-not-found=true -n istio-system secret mysql-credential

kubectl create -n istio-system secret generic mysql-credential \
--from-file=tls.key=$CERTS_ROOT/3_application/private/mysql-mutual-tls.jeremysolarz.app.key.pem \
--from-file=tls.crt=$CERTS_ROOT/3_application/certs/mysql-mutual-tls.jeremysolarz.app.cert.pem \
--from-file=ca.crt=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl apply -f istio-mysql.yaml