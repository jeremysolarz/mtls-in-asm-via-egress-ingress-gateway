gcloud config set project ${IGRESS_PROJECT}

gcloud container clusters get-credentials ${EGRESS_CLUSTER} --region ${EGRESS_LOCATION} --project ${EGRESS_PROJECT}
## In case of Anthos on AWS use the following command to get credentials:
#anthos-gke aws clusters get-credentials ${EGRESS_CLUSTER}

## In case of Anthos GKE On-Prem, use the following command to acess the clsuter:
#export KUBECONFIG=${EGRESS_CLUSTER_KUBECONFIG}
