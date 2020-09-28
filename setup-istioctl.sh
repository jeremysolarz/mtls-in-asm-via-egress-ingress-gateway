ASM_VERSION="1.6.8-asm.9"

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     OS=linux-amd64;;
    Darwin*)    OS=osx;;
    *)          exit;
esac

curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-${OS}.tar.gz
tar xzf istio-1.6.8-asm.9-osx.tar.gz

cd istio-1.6.8-asm.9
export PATH=$PWD/bin:$PATH