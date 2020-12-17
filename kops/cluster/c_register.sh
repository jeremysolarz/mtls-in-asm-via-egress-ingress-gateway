#!/bin/bash
<<<<<<< HEAD
#source env.txt
## TF vars
export PROJECT='${project-id}'
##

=======
source env.txt
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455
echo -e "This will enable the Anthos APIs in this project $PROJECT!\n 
Running this will create Anthos PAYG costs as describe here:\n
https://cloud.google.com/anthos/pricing
\n
\n
Only deleting all anthos cluster sources will stop charges. If you are done with your tests, please run the cleanup procedure"
gcloud services enable \
 --project=$PROJECT \
 container.googleapis.com \
 gkeconnect.googleapis.com \
 gkehub.googleapis.com \
 cloudresourcemanager.googleapis.com

echo "Creating and downloading GKE Hub Service Account"
gcloud iam service-accounts create gkehub-connect-sa --project=$PROJECT
gcloud projects add-iam-policy-binding $PROJECT \
 --member="serviceAccount:gkehub-connect-sa@$PROJECT.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

echo "Downloading json key to gkehub.json"
gcloud iam service-accounts keys create gkehub.json \
  --iam-account=gkehub-connect-sa@$PROJECT.iam.gserviceaccount.com \
  --project=$PROJECT
echo "Storing kOps kubeconfig in mtls-kubeconfig"
kops export kubecfg mtls.k8s.local --kubeconfig mtls-kubeconfig
echo "Registering kOps cluster into Anthos in project: $PROJECT"
gcloud container hub memberships register mtls-kops \
            --context=mtls.k8s.local \
            --service-account-key-file=gkehub.json \
            --kubeconfig=mtls-kubeconfig \
            --project=vch-anthos-demo
echo "Creating login token for CloudConsole (admin account!)"
kubectl create serviceaccount -n kube-system admin-user
kubectl create clusterrolebinding admin-user-binding \
  --clusterrole cluster-admin --serviceaccount kube-system:admin-user
SECRET_NAME=$(kubectl get serviceaccount -n kube-system admin-user \
  -o jsonpath='{$.secrets[0].name}')
echo "Copy this token and use it to login to your cluster in cloud console"
echo $(kubectl get secret -n kube-system ${SECRET_NAME} -o jsonpath='{$.data.token}' \
<<<<<<< HEAD
  | base64 -d | sed $'s/$/\\\n/g') >> kops-ksa.token
=======
  | base64 -d | sed $'s/$/\\\n/g')
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455
