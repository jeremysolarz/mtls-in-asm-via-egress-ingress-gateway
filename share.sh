gcloud config set project vch-anthos-demo

rm -rf certs
mkdir -p certs

cp -r 1_root certs
cp -r 2_intermediate certs
cp -r 3_application certs
cp -r 4_client certs

tar -czvf certs.tar.gz certs

gsutil cp certs.tar.gz gs://ingress-egress-mtls-certs

rm -rf certs
rm -rf certs.tar.gz

gsutil cp gs://ingress-egress-mtls-certs/certs.tar.gz .

tar -xzvf certs.tar.gz