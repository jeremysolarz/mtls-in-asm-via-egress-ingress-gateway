*“Copyright 202019 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.*
*Your use of it is subject to your agreements with Google.”*  
# Mutual-TLS encryption in ASM (via Egress and Ingress)

The following repository should help in setting up mTLS between two clusters via encryption at Egress / Ingress 
gateway.

## Prerequisites

 - If you use your local machine
   - Install and initialize the [Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts) (the gcloud command-line tool).
   - Install `git` command line tool.
 - Two Anthos clusters (tested with GKE, Anthos on AWS, Anthos attached cluster EKS K8s 1.16)
 - ASM installed on both clusters (tested with version ASM 1.6 - Istio 1.6.8)
 - If you want to use an Anthos on AWS cluster, follow 
   [Install GKE on AWS prerequisites](https://cloud.google.com/anthos/gke/docs/aws/how-to/prerequisites#anthos_gke_command-line_tool) / installation.
 
Copy the file env-vars.tmpl to another file (e.g. env-vars) and will it with the right values for egress and ingress clusters 
(the two Anthos clusters you created before, that have ASM installed). 

Source the newly created file with the appropriate environment variables e.g.
`source env-vars`

Afterwards you should have values for the following variables

```
EGRESS_PROJECT
EGRESS_CLUSTER
EGRESS_LOCATION

INGRESS_PROJECT
INGRESS_CLUSTER
INGRESS_LOCATION
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

## Installation

In the following sections we will showcase mTLS encryption for both HTTP and TCP endpoints.

First you need to create the certificates for client / server endpoints. The following command will

 - Clone a [git repository](https://github.com/nicholasjackson/mtls-go-example). 
 - Use the repository to start key file generation.
 - Generation a new directory (./certs) with the keys will be created. 

```
create-keys.sh
```

### HTTP encryption with HttpBin   

#### Create the server side.

```
cd server/httpbin-server
./create-server.sh
```               

After running that command you should see two test calls for httpbin/status/418 e.g. the Teapod service

#### Create the client side.

```
cd client/httpbin-client
./create-client.sh
```               

### TCP encryption with MySQL

