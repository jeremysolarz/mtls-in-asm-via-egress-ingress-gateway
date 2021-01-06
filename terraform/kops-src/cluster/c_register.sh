#!/bin/bash
#source env-vars
## TF vars
export PROJECT='${project}'
export LOCATION='${location}'
##

echo -e "This will enable the Anthos APIs in this project $PROJECT!\n 
Running this will create Anthos PAYG costs as describe here:\n
https://cloud.google.com/anthos/pricing
\n
\n
Only deleting all Anthos cluster sources will stop charges. If you are done with your tests, please run the cleanup procedure"

echo "Creating and downloading GKE Hub Service Account"
gcloud iam service-accounts create client-cluster-gke-hub-sa --project=$PROJECT
gcloud projects add-iam-policy-binding $PROJECT \
 --member="serviceAccount:client-cluster-gke-hub-sa@$PROJECT.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

echo "Downloading json key to gkehub.json"
gcloud iam service-accounts keys create gkehub.json \
  --iam-account=client-cluster-gke-hub-sa@$PROJECT.iam.gserviceaccount.com \
  --project=$PROJECT
echo "Storing kOps kubeconfig in mtls-kubeconfig"
kops export kubecfg server-cluster.local --kubeconfig $LOCATION/server-kubeconfig --state "gs://$PROJECT-kops-clusters/"/
echo "Registering kOps cluster into Anthos in project: $PROJECT"
gcloud container hub memberships register server-cluster \
            --context=server-cluster.local \
            --service-account-key-file=gkehub.json \
            --kubeconfig=$LOCATION/mtls-kubeconfig \
            --project=$PROJECT \
            --quiet
echo "Creating login token for CloudConsole (admin account!)"
kubectl --kubeconfig $LOCATION/server-kubeconfig create serviceaccount -n kube-system admin-user
kubectl --kubeconfig $LOCATION/server-kubeconfig create clusterrolebinding admin-user-binding \
  --clusterrole cluster-admin --serviceaccount kube-system:admin-user
SECRET_NAME=$(kubectl --kubeconfig $LOCATION/server-kubeconfig get serviceaccount -n kube-system admin-user \
  -o jsonpath='{$.secrets[0].name}')
echo "Copy this token and use it to login to your cluster in cloud console"
echo $(kubectl --kubeconfig $LOCATION/server-kubeconfig get secret -n kube-system $SECRET_NAME -o jsonpath='{$.data.token}' \
  | base64 -d | sed $'s/$/\\\n/g') >> kops-ksa.token
