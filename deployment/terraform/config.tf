# ---------------------------------------------------------------------------------------------------
# --- general google cloud inputs
# ---------------------------------------------------------------------------------------------------

variable "project" {
    default = "monarch-initiative"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "credentials_file" {
  type = string
  description = "The path to a credentials file for a user/service account with permission to edit resources in your target project"
}

variable "svc_account_id" {
  type = string
  description = "The ID (either email or unique ID) of the service account under which the VMs will run"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.54.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

# ---------------------------------------------------------------------------------------------------
# --- stack-specific inputs
# ---------------------------------------------------------------------------------------------------

variable "prefix" {
  default = "tf-monarch-"
  type = string
  description = "the prefix to put before each entity's name on creation; if empty, no prefix is used"
}

variable "virtual_machines" {
  default = {
    manager = { 
      machine_type = "e2-small"
      role = "manager"
      services = []
    }

    owlsim = { 
      machine_type = "e2-highmem-8"
      role = "worker"
      services = ["owlsim"]
      disk_size_gb = 20
    }

    scigraph = { 
      machine_type = "e2-highmem-4"
      role = "worker"
      services = ["scigraph-data", "scigraph-ontology"]
      disk_size_gb = 125 # 107GB in /srv/monarch, 111GB total
      disk_type = "pd-standard"
    }

    solr = { 
      machine_type = "e2-standard-4"
      role = "worker"
      services = ["solr", "biolink", "ui"]
      disk_size_gb = 250 # 223GB in /srv/monarch, 228GB total
      disk_type = "pd-standard"
    }
  }
}
