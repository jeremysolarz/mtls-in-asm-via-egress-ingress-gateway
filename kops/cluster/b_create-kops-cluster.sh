#!/bin/bash
source ../env.txt
echo "Installing and running kops clsuter now"
kops create cluster mtls.k8s.local --zones us-central1-a --state ${KOPS_STATE_STORE}/ --project=${PROJECT}
echo "Cluster object has been created:"
kops get cluster --state ${KOPS_STATE_STORE}
echo "Starting cluster instances now"
kops update cluster mtls.k8s.local --yes