*“Copyright 202019 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.*
*Your use of it is subject to your agreements with Google.”*  
# Mutual-TLS encryption in ASM (via Egress and Ingress)

The following repository should help in setting up mTLS between two clusters via encryption at Egress / Ingress 
gateway.

## Before you begin

 - If you use your local machine
   - Install and initialize the [Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts) (the gcloud command-line tool).
   - Install `git` command line tool.
   - Install `terraform` command line tool.

 - Setup you environment to have PROJECT_ID, REGION and ZONE
   ```
   export PROJECT_ID=YOUR_PROJECT_ID
   export REGION=GCP_REGION
   export ZONE=GCP_ZONE
 
   gcloud config set project ${PROJECT_ID}
   gcloud config set compute/region ${REGION}
   gcloud config set compute/zone ${ZONE}
   ```
 - Enable the APIs needed for the tutorial:
   ```
   gcloud services enable \
       compute.googleapis.com \
       container.googleapis.com \
       cloudresourcemanager.googleapis.com \
       stackdriver.googleapis.com \
       monitoring.googleapis.com \
       logging.googleapis.com \
       cloudtrace.googleapis.com \
       meshca.googleapis.com \
       meshtelemetry.googleapis.com \
       meshconfig.googleapis.com \
       iamcredentials.googleapis.com \
       gkeconnect.googleapis.com \
       gkehub.googleapis.com
    ```

### Optional (Terraform scripts provided for 2 GCP clusters with ASM)
 
 - Two Anthos clusters (tested with GKE, Anthos on AWS, Anthos attached cluster EKS K8s 1.16)
 - ASM installed on both clusters (tested with version ASM 1.6 - Istio 1.6.8)
   - [Egress via egress gateways](https://cloud.google.com/service-mesh/docs/enable-optional-features#egress_gateways) via optional features enabled
   - [Direct Envoy to stdout](https://cloud.google.com/service-mesh/docs/enable-optional-features#direct_envoy_to_stdout) via optional features enabled 
 - If you want to use an Anthos on AWS cluster, follow 
   [Install GKE on AWS prerequisites](https://cloud.google.com/anthos/gke/docs/aws/how-to/prerequisites#anthos_gke_command-line_tool) / installation.

## Installation

Depending on if you already have two Anthos GKE clusters with ASM installed or not you can skip the next step.

### Client / Server cluster setup via Terraform

1. Change into the terraform folder
   ```
   cd terraform
   ```

1. Create a terraform.tfvars file (based on the environment variables you created before)
   ```
   cat << EOF > terraform.tfvars
   project_id = "${PROJECT_ID}"
   region = "${REGION}"
   zones = ["${ZONE}"]
   EOF
   ```

1. Run the Terraform scripts to setup client / server cluster.
   ```
   terraform init
   terraform plan
   
   terraform apply --auto-approve
   
   cd ..
   ```

### ASM Configuration

In the following sections we fill showcase mTLS encryption for both HTTP and TCP endpoints.

As the DNS name for the Ingress Gateway we use [nip.io](nip.io). Which gives us the possibility to resolve the
Ingress IP as DNS name e.g. 192.168.0.1.nip.io resolves to 192.168.0.1  

First you need to create the certificates for client / server endpoints. The following command will

 - Clone a [git repository](https://github.com/nicholasjackson/mtls-go-example). 
 - Use the repository to start key file generation.
 - Generation a new directory (./certs) with the keys will be created. 

```
./create-keys.sh
```

*Note:*
Client / Server certificates will be created with [mtls-go-example](https://github.com/nicholasjackson/mtls-go-example)
and are expected to be in a fixed location. If you have already your own certificates you need to copy them in the right 
locations.

```
./2_intermediate/certs/ca-chain.cert.pem
./4_client/private/<YOUR_SERVICE_URL>.key.pem
./4_client/certs/<YOUR_SERVICE_URL>.cert.pem 
``` 

### Create client / server (HTTP & MySQL)

#### HTTP encryption with HttpBin   

The following sections deploy a httpbin server on the server cluster and a sleeper pod (curl capable) on the client 
cluster. Encrypted communication will happen transparently for client / server via Egress / Ingress Gateways.

##### Create the server side.

```
cd server/httpbin-server
./create-server.sh
```               

After running the above command you should see two test calls for httpbin/status/418 e.g. the Teapod service resulting in
a output like this.

```
    -=[ teapot ]=-

       _...._
     .'  _ _ `.
    | ."` ^ `". _,
    \_;`"---"`|//
      |       ;/
      \_     _/
        `"""`
```

Now as a final check see if the sidecar proxy was injected properly into the server.

Run
```
kubectl get pods -n default
```

You should see output similar to this:

```
NAME                       READY   STATUS    RESTARTS   AGE
httpbin-779c54bf49-4tg9h   2/2     Running   0          71s
```

Go back to the root directory.

```
cd ../..
```               

##### Create the client side.

The client creates a sleeper pod (`image: tutum/curl) that calls the httpbin server side.

```
cd client/httpbin-client
./create-client.sh
```               

Go back to the root directory.

```
cd ../..
```     

The `create-client.sh` command automatically runs some checks that the setup works. E.g. 
`curl -v http://${SERVICE_URL}/status/418` from the "sleeper" pod.

If you want to test for yourself you can connect to the sleeper pod (make sure your cluster context is set to the client cluster).

```
kubectl exec deploy/sleep -it -- /bin/bash
```

Once you have connected to the sleeper pod you can also run a check via it's alias name

```
curl -v http://httpbin-external/status/418
```

### Bonus / Troubleshooting

The see what's going on between client and server you can use the following helper scripts:

#### Client

Show the proxy logs of the sleeper pod:

`client/httpbin-client/get-logs-from-sleep-proxy.sh`

Show the logs of the egress proxy:

`client/get-logs-from-egress.sh`

#### Server

Show the logs of the ingress proxy:

`server/get-logs-from-ingress.sh`

#### TCP encryption with MySQL

##### Create the server side.

```
cd server/mysql-server
./create-server.sh
```               

Now as a final check see if the sidecar proxy was injected properly into the server.

Run
```
kubectl get pods -n default
```

You should see output similar to this:

```
NAME                       READY   STATUS    RESTARTS   AGE
mysql-5bf4c56867-sjs7m   2/2     Running   0          71s
```

Go back to the root directory.

```
cd ../..
```         

After running the above command you should 

##### Create the client side.
```
cd client/mysql-client
./create-client.sh
```   