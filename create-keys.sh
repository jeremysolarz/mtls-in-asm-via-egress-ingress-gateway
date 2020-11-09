./server/set-project-and-cluster-server.sh

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

rm -rf certs
mkdir certs
git clone git@github.com:nicholasjackson/mtls-go-example.git
cd mtls-go-example
# delete old certs
rm -rf 1_root 2_intermediate 3_application 4_client
echo "Please enter a password for your security keys: "
read SECURE_PASSWORD

yes | ./generate.sh $INGRESS_HOST.nip.io $SECURE_PASSWORD
mv 1_root ../certs
mv 2_intermediate ../certs
mv 3_application ../certs
mv 4_client ../certs