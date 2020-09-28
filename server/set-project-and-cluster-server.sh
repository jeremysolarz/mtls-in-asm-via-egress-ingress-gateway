gcloud config set project ${INGRESS_PROJECT}

gcloud container clusters get-credentials ${INGRESS_CLUSTER} --region ${INGRESS_LOCATION} --project ${INGRESS_PROJECT}
