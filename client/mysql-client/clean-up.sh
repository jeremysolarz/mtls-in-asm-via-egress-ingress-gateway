gcloud config set project vch-anthos-demo

gcloud container clusters get-credentials anthos-gcp --region europe-west4 --project vch-anthos-demo

kubectl delete --ignore-not-found=true -f se-mysql.yaml
kubectl delete --ignore-not-found=true secret httpbin-client-certs httpbin-ca-certs
kubectl delete --ignore-not-found=true secret httpbin-client-certs httpbin-ca-certs -n istio-system

# reset ASM
istioctl install \
  -f ../../../istio-1.6.8-asm.9/asm/cluster/istio-operator.yaml \
-f ../features.yaml

kubectl get deploy -n istio-system
kubectl get ns