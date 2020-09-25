kubectl delete --ignore-not-found=true gateway mygateway
kubectl delete --ignore-not-found=true virtualservice httpbin
kubectl delete --ignore-not-found=true -n istio-system secret httpbin-credential httpbin-credential-cacert
