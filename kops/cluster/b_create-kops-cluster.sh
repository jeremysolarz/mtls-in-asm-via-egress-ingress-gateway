#!/bin/bash

## TF vars
export PROJECT='${project}'
export GCPZONE='${zone}'
export KOPS_FEATURE_FLAGS='${kops-gce}'
###

# Make those eventually configurable - but for now they are fixed

#source ../env-vars
echo "Installing and running kops cluster now"
kops create cluster mtls.k8s.local --zones $GCPZONE --state $PROJECT-kops-clusters/ --project=$PROJECT
#echo "Cluster object has been created:"
echo "Starting cluster instances now"
kops update cluster mtls.k8s.local --yes