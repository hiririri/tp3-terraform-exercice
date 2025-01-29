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

resource "google_artifact_registry_repository" "my_repository" {
  provider = google-beta
  project = "${var.project}"
  location      = "${var.region}"
  repository_id = "${var.artifact_repo_name}"
  format        = "DOCKER"
}

resource "google_cloud_run_service" "node_app" {
  name     = "${var.service_name}"
  location = "${var.region}"
  project = "${var.project}"

  template {
    spec {
      containers {
        ports {
          container_port = 80
        }
        image = "${var.region}-docker.pkg.dev/${var.project}/${var.artifact_repo_name}/node-app:${var.branch_name}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}