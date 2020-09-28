./server/set-project-and-cluster-server.sh

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

rm -rf certs
mkdir certs
cd mtls-go-example
# delete old certs
rm -rf 1_root 2_intermediate 3_application 4_client
yes | ./generate.sh $INGRESS_HOST.nip.io mysupersecurepassword
mv 1_root ../certs
mv 2_intermediate ../certs
mv 3_application ../certs
mv 4_client ../certs