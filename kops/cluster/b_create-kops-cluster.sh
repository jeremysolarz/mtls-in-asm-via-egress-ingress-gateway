#!/bin/bash

## TF vars
export PROJECT='${project}'
export GCPZONE='${zone}'
export KOPS_FEATURE_FLAGS='${kops-gce}'
###

# Make those eventually configureable - but for now they are fixed

#source ../env.txt
echo "Installing and running kops clsuter now"
kops create cluster mtls.k8s.local --zones $GCPZONE --state $PROJECT-kops-clusters/ --project=$PROJECT
#echo "Cluster object has been created:"
#kops get cluster --state ${KOPS_STATE_STORE}
echo "Starting cluster instances now"
kops update cluster mtls.k8s.local --yes