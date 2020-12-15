gcloud compute firewall-rules list --filter="name=example-vpc" \
  --format="value(name)" | xargs -I {} gcloud compute firewall-rules delete {} -q