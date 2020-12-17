#!/bin/bash
echo -e "Please select OS for kOps instllation:\n 1: MacOS\n 2: Linux"
read choice

case $choice in
1) 
    echo "Installing kOps for MacOs now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-darwin-amd64
    chmod +x ./kops
    sudo mv ./kops /usr/local/bin/
    echo "Done dowwnloading"
    ;;
2)
    echo "Insallin kOps for Linux now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x ./kops
    sudo mv ./kops /usr/local/bin/
    echo "Done downloading kops"
    ;;
*) 
    echo "Invalid choice, please only input the number next to your OS"
    exit 1
    ;;
esac

echo "Setting envs file now"
PROJECT=$(gcloud config get-value project)
echo "Generating kops bucket"
gsutil mb gs://$PROJECT-kops-clusters
echo "export PROJECT=$PROJECT" > ../env.txt
echo "export KOPS_STATE_STORE=gs://$PROJECT-kops-clusters" >> ../env.txt
echo "export KOPS_FEATURE_FLAGS=AlphaAllowGCE" >> ../env.txt



