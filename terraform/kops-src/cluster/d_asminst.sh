#!/bin/bash
#source env-vars
## TF vars
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCATION="$DIR/../.."
##

ASM_VERSION="1.6.11-asm.1"
ASM_REVISION="1611-1"

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     OS=linux-amd64;;
    Darwin*)    OS=osx;;
    *)          echo "Oh snap! It seems ASM is not yet available for your OS: $uname_out"; exit1;
esac

ASM_SUFFIX=${ASM_VERSION}-${OS}

uname_out="$(uname -s)"
echo -e "Installing ASM for OS $uname_out into $LOCATION"

echo "Downloading ASM installation files"
gsutil cp gs://gke-release/asm/istio-${ASM_SUFFIX}.tar.gz $LOCATION/
echo "Done downloading"
echo "Unpacking download and preparing install"
tar xzf $LOCATION/istio-${ASM_SUFFIX}.tar.gz

# Installing ASM
echo "Preparing istio installation"
cd istio-${ASM_VERSION}
kubectl --kubeconfig $LOCATION/server-kubeconfig create namespace istio-system
# Create webhook version
echo "Creating webhook for version asm-${ASM_REVISION}"
cat <<EOF > $LOCATION/istiod-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: istiod
  namespace: istio-system
  labels:
    istio.io/rev: asm-${ASM_REVISION}
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
    istio.io/rev: asm-${ASM_REVISION}
EOF
# Run istioctl isntallation
echo "Installing istio into the cluster"
bin/istioctl install --set profile=asm-multicloud --set revision=asm-${ASM_REVISION} -f $LOCATION/server/features.yaml
kubectl --kubeconfig $LOCATION/server-kubeconfig apply -f $LOCATION/istiod-service.yaml
# Inject sidecare proxies
kubectl --kubeconfig $LOCATION/server-kubeconfig label namespace default istio-injection- istio.io/rev=asm-${ASM_REVISION} --overwrite
echo "Done installing istio into the cluster"