#!/bin/bash

## Terraform vars
export PROJECT='${project_id}'
##

uname_out="$(uname -s)"
echo -e "Installing kOps for OS $uname_out"

case $uname_out in
Darwin*) 
    echo "Installing kOps for MacOs now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-darwin-amd64
    chmod +x ./kops
    sudo mv ./kops /usr/local/bin/
    echo "Done dowwnloading"
    ;;
Linux*)
    echo "Insallin kOps for Linux now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x ./kops
    sudo mv ./kops /usr/local/bin/
    echo "Done downloading kops"
    ;;
*) 
    echo "Oh snap! It seems kOps is not yet available for your OS: $uname_out"
    exit 1
    ;;
esac

echo "Setting envs file now"
PROJECT=$(gcloud config get-value project)
echo ""
echo "Generating kops bucket"
gsutil mb gs://$PROJECT-kops-clusters



