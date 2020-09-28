#!/bin/bash
#
# Written by vhamburger@google.com 28.09.2020.
# Copyright 202019 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.
# Your use of it is subject to your agreements with Google.”#
# This script is not intended to create a production grade setup of mysql. Please use as a tempalte for a test or PoC environment,
# but not for production implemmentation.

#Varibles:
TOPDIR=${0}


# Environment:
function setenv ()
{
    echo "Please select the GKE cluster for running the mysql server:"
    echo "1: GKE"
    echo "2: Anthos GKE On-Prem"
    echo "3: Anthos GKE on AWS"
    read INPUT
    case $INPUT in 
        "1"*)
        eval $1="GKE"
        ;;
        "2"*)
        eval $1="OP"
        ;;
        "3"*)
        eval $1="AWS"
        ;;
        *)
        echo "Not a valid choice - aborting"
        exit 1
        ;;
    esac
}

#Set the server environment
setenv SERVENV

# Perform specific task per env
case $SERVENV in
    "GKE"*)
    echo "We have GKE here"
    echo "Please enter your $SERVENV mysql server project name: "
    read INGRESS_PROJECT 
    export INGRESS_PROJECT
    echo "Please enter your $SERVENV mysql cluster name: "
    read INGRESS_CLUSTER
    export INGRESS_CLUSTER
    echo "Please enter your $SERVENV mysql location: "
    read INGRESS_LOCATION
    export INGRESS_LOCATION

    # Set the project and get access to the GKE cluster
    gcloud config set project ${IGRESS_PROJECT}
    gcloud container clusters get-credentials ${EGRESS_CLUSTER} --region ${EGRESS_LOCATION} --project ${EGRESS_PROJECT}
    #instgke
    ;;
    "OP"*)
    echo "We have On Prem here"
    echo "Please provide the full path to your user cluster kubeconfig here: "
    read KUBECONFIG
    export KUBECONFIG
    ;;
    "AWS"*)
    echo "We have AWS here"
    echo "Please proide your $SERVENV cluster name: "
    read AWSCLNAME
    export AWSCLNAME
    echo "Please provide the Anthos on $SERVENV setup directory (no trailing \):"
    read AWSPATH
    # Get access to the GKE on AWS cluster
    angkepath=$(which anthos-gke)
    if [ $? -ge 1 ] 
      then
        echo "Seems like anthos-gke is not installe - aborting"
        exit 1
    fi
    echo $AWSCLNAME
    cd $AWSPATH
    $angkepath aws clusters get-credentials $AWSCLNAME
    cd $TOPDIR
    ;;
    *)
    echo "We have a problem here"
    ;;
esac
#CLENV=env