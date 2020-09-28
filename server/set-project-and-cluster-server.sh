gcloud config set project ${INGRESS_PROJECT}

<<<<<<< HEAD
gcloud container clusters get-credentials ${EGRESS_CLUSTER} --region ${EGRESS_LOCATION} --project ${EGRESS_PROJECT}
## In case of Anthos on AWS use the following command to get credentials:
#anthos-gke aws clusters get-credentials ${EGRESS_CLUSTER}

## In case of Anthos GKE On-Prem, use the following command to acess the clsuter:
#export KUBECONFIG=${EGRESS_CLUSTER_KUBECONFIG}
=======
gcloud container clusters get-credentials ${INGRESS_CLUSTER} --region ${INGRESS_LOCATION} --project ${INGRESS_PROJECT}
>>>>>>> 28b7aec59df49f3db7ada389b4bfa74afa9147d0
