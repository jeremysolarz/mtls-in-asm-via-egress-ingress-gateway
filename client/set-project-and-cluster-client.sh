gcloud config set project ${EGRESS_PROJECT}

gcloud container clusters get-credentials ${EGRESS_CLUSTER} --region ${EGRESS_LOCATION} --project ${EGRESS_PROJECT}