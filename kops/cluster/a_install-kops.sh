#!/bin/bash
<<<<<<< HEAD

## Terraform vars
export PROJECT='${project_id}'
##

uname_out="$(uname -s)"
echo -e "Installing kOps for OS $uname_out"

case $uname_out in
Darwin*) 
=======
echo -e "Please select OS for kOps instllation:\n 1: MacOS\n 2: Linux"
read choice

case $choice in
1) 
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455
    echo "Installing kOps for MacOs now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-darwin-amd64
    chmod +x ./kops
    sudo mv ./kops /usr/local/bin/
    echo "Done dowwnloading"
    ;;
<<<<<<< HEAD
Linux*)
=======
2)
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455
    echo "Insallin kOps for Linux now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x ./kops
    sudo mv ./kops /usr/local/bin/
    echo "Done downloading kops"
    ;;
*) 
<<<<<<< HEAD
    echo "Oh snap! It seems kOps is not yet available for your OS: $uname_out"
=======
    echo "Invalid choice, please only input the number next to your OS"
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455
    exit 1
    ;;
esac

echo "Setting envs file now"
PROJECT=$(gcloud config get-value project)
<<<<<<< HEAD
echo ""
echo "Generating kops bucket"
gsutil mb gs://$PROJECT-kops-clusters
=======
echo "Generating kops bucket"
gsutil mb gs://$PROJECT-kops-clusters
echo "export PROJECT=$PROJECT" > ../env.txt
echo "export KOPS_STATE_STORE=gs://$PROJECT-kops-clusters" >> ../env.txt
echo "export KOPS_FEATURE_FLAGS=AlphaAllowGCE" >> ../env.txt
>>>>>>> 4de4955a8e00273dc7e70bafdd051c50d9dc0455



