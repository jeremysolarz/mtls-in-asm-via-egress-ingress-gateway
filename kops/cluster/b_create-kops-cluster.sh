#!/bin/bash

## TF vars
export PROJECT='${project}'
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
echo "Starting cluster instances now"
kops update cluster mtls.k8s.local --yes