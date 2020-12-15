/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  region  = var.region
}

locals {
  client_cluster_name   = "client-cluster"
  client_cluster_subnet = "client-cluster-subnet"

  server_cluster_name   = "server-cluster"
  server_cluster_subnet = "server-cluster-subnet"

  vpc_name              = "example-vpc"
}

data "google_project" "project" {
  project_id = var.project_id
}

module "vpc" {
  # destroy gke fw rules, otherwise you can not delete the vpc
  /*
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
gcloud compute firewall-rules list --filter='name=${local.vpc_name}' \
  --format='value(name)' | xargs -I {} gcloud compute firewall-rules delete {} -q"
EOF
  }
  */

  source = "terraform-google-modules/network/google"

  project_id = var.project_id
  network_name = local.vpc_name

  subnets = [
    {
      subnet_name = local.client_cluster_subnet
      subnet_ip = "10.10.0.0/16"
      subnet_region = var.region
    },
    {
      subnet_name = local.server_cluster_subnet
      subnet_ip = "10.20.0.0/16"
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
    "${local.client_cluster_subnet}" = [
      {
        range_name    = "${local.client_cluster_subnet}-pods"
        ip_cidr_range = "192.168.0.0/21"
      },
      {
        range_name    = "${local.client_cluster_subnet}-services"
        ip_cidr_range = "192.168.8.0/21"
      }
    ]

    "${local.server_cluster_subnet}" = [
      {
        range_name    = "${local.server_cluster_subnet}-pods"
        ip_cidr_range = "192.168.16.0/21"
      },
      {
        range_name    = "${local.server_cluster_subnet}-services"
        ip_cidr_range = "192.168.24.0/21"
      }
    ]
  }

}

# client cluster

# todo rename to client-cluster
module "gke" {
  source                  = "terraform-google-modules/kubernetes-engine/google//"
  project_id              = var.project_id
  name                    = local.client_cluster_name
  regional                = false
  region                  = var.region
  zones                   = var.zones
  release_channel         = "REGULAR"
  network                 = module.vpc.network_name
  subnetwork              = local.client_cluster_subnet
  ip_range_pods           = "${local.client_cluster_subnet}-pods"
  ip_range_services       = "${local.client_cluster_subnet}-services"
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  node_pools = [
    {
      name         = "asm-node-pool"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]
}

# todo rename to client-cluster-asm
module "asm" {
  # todo change to github.com/jeremysolarz/terraform-google-modules/kubernetes-engine/google//modules/asm
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  cluster_name     = module.gke.name
  cluster_endpoint = module.gke.endpoint
  project_id       = var.project_id
  location         = module.gke.location
}

data "google_client_config" "default" {
}

# todo rename to client-cluster-hub
module "hub" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/hub"
  project_id              = var.project_id
  location                = module.gke.location
  cluster_name            = module.gke.name
  cluster_endpoint        = module.gke.endpoint
  # todo add prefix for "${local.client_cluster_name}-asm-membership"
  gke_hub_membership_name = "gke-asm-membership"
  # todo add Service Account for client (don't use default)
}

# server cluster

module "server-cluster" {
  source                  = "terraform-google-modules/kubernetes-engine/google//"
  project_id              = var.project_id
  name                    = local.server_cluster_name
  regional                = false
  region                  = var.region
  zones                   = var.zones
  release_channel         = "REGULAR"
  network                 = module.vpc.network_name
  subnetwork              = local.server_cluster_subnet
  ip_range_pods           = "${local.server_cluster_subnet}-pods"
  ip_range_services       = "${local.server_cluster_subnet}-services"
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  node_pools = [
    {
      name         = "asm-node-pool"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]
}

module "server-cluster-asm" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"

  project_id       = var.project_id

  cluster_name     = module.server-cluster.name
  cluster_endpoint = module.server-cluster.endpoint
  location         = module.server-cluster.location
}

/** TODO add back once cluster creation is in separate files
data "google_client_config" "default" {
}
*/

module "server-cluster-hub" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/hub"
  project_id              = var.project_id
  location                = module.server-cluster.location
  cluster_name            = module.server-cluster.name
  cluster_endpoint        = module.server-cluster.endpoint
  gke_hub_membership_name = "${local.server_cluster_name}-asm-membership"
  gke_hub_sa_name         = "${local.server_cluster_name}-gke-hub-sa"
}