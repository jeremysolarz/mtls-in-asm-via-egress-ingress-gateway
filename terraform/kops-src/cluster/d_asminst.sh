#!/bin/bash
#source env-vars
## TF vars
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCATION="$DIR/../../"
##

uname_out="$(uname -s)"
echo -e "Installing ASM for OS $uname_out into $LOCATION"

echo "Downloading ASM installation files"
case $uname_out in
Darwin*) 
    echo "Downloading ASM for MacOs now"
    gsutil cp gs://gke-release/asm/istio-1.6.11-asm.1-osx.tar.gz $LOCATION/
    echo "Done downloading"
    echo "Unpacking download and preparing install"
    tar xzf $LOCATION/istio-1.6.11-asm.1-osx.tar.gz
    ;;
Linux*)
    echo "Downloading ASM for Linux now"
    gsutil cp gs://gke-release/asm/istio-1.6.11-asm.1-linux-amd64.tar.gz
    echo "Done downloading"
    echo "Unpacking download and preparing install"
    tar xzf $LOCATION/istio-1.6.11-asm.1-osx.tar.gz
    ;;
*) 
    echo "Oh snap! It seems kOps is not yet available for your OS: $uname_out"
    exit 1
    ;;
esac
# Installing ASM
echo "Preparing istio installation"
cd istio-1.6.11-asm.1
kubectl --kubeconfig $LOCATION/server-kubeconfig create namespace istio-system
# Create webhook version
echo "Creating webhook for version asm-1611-1"
cat <<EOF > $LOCATION/istiod-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: istiod
  namespace: istio-system
  labels:
    istio.io/rev: asm-1611-1
    app: istiod
    istio: pilot
    release: istio
spec:
  ports:
    - port: 15010
      name: grpc-xds # plaintext
      protocol: TCP
    - port: 15012
      name: https-dns # mTLS with k8s-signed cert
      protocol: TCP
    - port: 443
      name: https-webhook # validation and injection
      targetPort: 15017
      protocol: TCP
    - port: 15014
      name: http-monitoring # prometheus stats
      protocol: TCP
  selector:
    app: istiod
    istio.io/rev: asm-1611-1
EOF
# Run istioctl isntallation
echo "Installing istio into the cluster"
bin/istioctl install --set profile=asm-multicloud --set revision=asm-1611-1 -f $LOCATION/server/features.yaml
kubectl --kubeconfig $LOCATION/server-kubeconfig apply -f $LOCATION/istiod-service.yaml
# Inject sidecare proxies
kubectl --kubeconfig $LOCATION/server-kubeconfig label namespace default istio-injection- istio.io/rev=asm-1611-1 --overwrite
ecbo "Done installing istio into the cluster"