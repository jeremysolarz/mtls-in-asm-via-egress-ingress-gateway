#!/bin/bash
<<<<<<< HEAD

## TF vars
export PROJECT='${project-id}'
export GCPZONE='${zone}'
###

# Make those eventually configureable - but for now they are fixed
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=$PROJECT-kops-clusters
#source ../env.txt
echo "Installing and running kops clsuter now"
kops create cluster mtls.k8s.local --zones $GCPZONE --state ${KOPS_STATE_STORE}/ --project=${PROJECT}
#echo "Cluster object has been created:"
#kops get cluster --state ${KOPS_STATE_STORE}
=======
source ../env.txt
echo "Installing and running kops clsuter now"
kops create cluster mtls.k8s.local --zones us-central1-a --state ${KOPS_STATE_STORE}/ --project=${PROJECT}
echo "Cluster object has been created:"
kops get cluster --state ${KOPS_STATE_STORE}
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455
echo "Starting cluster instances now"
kops update cluster mtls.k8s.local --yes