*“Copyright 202019 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.*
*Your use of it is subject to your agreements with Google.”*  
# Mutual-TLS encryption in ASM (via Egress and Ingress)

The following repository should help in setting up mTLS between two clusters via encryption at Egress / Ingress 
gateway.

## Prerequisites

 - If you use your local machine
   - Install and initialize the [Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts) (the gcloud command-line tool).
   - Install `git` command line tool.
   - Install `terraform` command line tool.

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

Run the Terraform scripts to setup client / server cluster.

```
cd terraform
terraform init
terraform plan

terraform apply --auto-approve
```

### Environment setup
 
Copy the file env-vars.tmpl to another file (e.g. env-vars) and will it with the right values for egress and ingress clusters 
(the two Anthos clusters you created before, that have ASM installed).
Note: If you used Terraform to create the client / server clusters use client-cluster for EGRESS_CLUSTER and 
server-clusters for INGRESS_CLUSTER.

Source the newly created file with the appropriate environment variables e.g.
`source env-vars`

Afterwards you should have values for the following variables

```
echo "==== EGRESS ===="
echo $EGRESS_PROJECT
echo $EGRESS_CLUSTER
echo $EGRESS_LOCATION

echo "==== INGRESS ===="
echo $INGRESS_PROJECT
echo $INGRESS_CLUSTER
echo $INGRESS_LOCATION
```

If you used Terraform it should look something like

```
==== EGRESS ====
your-project-id
client-cluster
us-central1-c
==== INGRESS ====
your-project-id
server-cluster
us-central1-c
```

Keep in mind that the egress cluster is the client and the ingress cluster is the server side.

*Note:*
Client / Server certificates will be created with [mtls-go-example](https://github.com/nicholasjackson/mtls-go-example)
and are expected to be in a fixed location. If you have already your own certificates you need to copy them in the right 
locations.

```
./2_intermediate/certs/ca-chain.cert.pem
./4_client/private/<YOUR_SERVICE_URL>.key.pem
./4_client/certs/<YOUR_SERVICE_URL>.cert.pem 
``` 

As the DNS name for the Ingress Gateway we use [nip.io](nip.io). Which gives us the possibility to resolve the
Ingress IP as DNS name e.g. 192.168.0.1.nip.io resolves to 192.168.0.1  

### ASM Configuration

In the following sections we will showcase mTLS encryption for both HTTP and TCP endpoints.

First you need to create the certificates for client / server endpoints. The following command will

 - Clone a [git repository](https://github.com/nicholasjackson/mtls-go-example). 
 - Use the repository to start key file generation.
 - Generation a new directory (./certs) with the keys will be created. 

```
./create-keys.sh
```

#### HTTP encryption with HttpBin   

##### Create the server side.

```
cd server/httpbin-server
./create-server.sh
```               

After running the above command you should see two test calls for httpbin/status/418 e.g. the Teapod service

Go back to the root directory.

```
cd ../..
```               

##### Create the client side.

```
cd client/httpbin-client
./create-client.sh
```               

The `create-client.sh` command automatically runs some checks that the setup works. E.g. 
`curl -v http://${SERVICE_URL}/status/418` from the "sleeper" pod.

#### TCP encryption with MySQL

##### Create the server side.

##### Create the client side.
