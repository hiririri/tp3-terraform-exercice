# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  env = "dev"
}

provider "google" {
  project = "${var.project}"
}

resource "google_artifact_registry_repository" "my-repository" {
  repository_id = "my-repository"
  location      = "us-central1"
  format        = "DOCKER"
}

# Cloud Run Deployment
resource "google_cloud_run_v2_service" "node_app" {
  name     = "node-app"
  location = "us-central1"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/${var.project}/docker-repo/node-app:latest"
    }
  }
}

module "vpc" {
  source  = "../../modules/vpc"
  project = "${var.project}"
  env     = "${local.env}"
}

module "http_server" {
  source  = "../../modules/http_server"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}

module "firewall" {
  source  = "../../modules/firewall"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}
