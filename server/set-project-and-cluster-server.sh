DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../env-vars

gcloud config set project ${INGRESS_PROJECT}

gcloud container clusters get-credentials ${INGRESS_CLUSTER} --region ${INGRESS_LOCATION} --project ${INGRESS_PROJECT}

## In case of Anthos on AWS use the following command to get credentials:
#anthos-gke aws clusters get-credentials ${EGRESS_CLUSTER}

## In case of Anthos GKE On-Prem, use the following command to acess the clsuter:
#export KUBECONFIG=${EGRESS_CLUSTER_KUBECONFIG}