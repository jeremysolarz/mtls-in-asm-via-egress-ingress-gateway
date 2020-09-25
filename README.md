# Mutual-TLS encryption in ASM (via Egress and Ingress)

The following repository should help in setting up mTLS between two clusters via encryption at Egress / Ingress 
gateway.

*“Copyright 202019 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.*
*Your use of it is subject to your agreements with Google.”*  

## Prerequesists

 - Two Anthos clusters (tested with GKE, Anthos on AWS, Anthos attached cluster EKS K8s 1.16)
 - ASM installed on both clusters (tested with version ASM 1.6 - Istio 1.6.8)
 - Client / Server certificates (tested with [mtls-go-example](https://github.com/nicholasjackson/mtls-go-example))
 
## Installation

In the following sections we will showcase mTLS encryption for both HTTP and TCP endpoints.

### HTTP encryption with HttpBin

### TCP encryption with MySQL

