The following scripts can be used for troubleshooting your setup

```
# get logs of ingressgateway
kubectl logs -n istio-system "$(kubectl get pod -l istio=ingressgateway \
-n istio-system -o jsonpath='{.items[0].metadata.name}')" -f

# get logs from httpbin server
kubectl logs -l app=httpbin -c istio-proxy -f

# get logs from mysql server
kubectl logs -l app=mysql -c istio-proxy -f
```