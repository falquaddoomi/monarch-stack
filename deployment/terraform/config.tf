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
    # default = ".secrets/monarch-initiative-bd310387f7b1.json"
    default = ".secrets/monarch-initiative-a9a59050572d.json"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.53"
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

variable "base_domain" {
  default = "monarch-gcp-balanced.ddns.net"
}

variable "services" {
  default = {
    "biolink" = {
      port = 5000
      healthcheck_path = "/"
    }
    "owlsim" = {
      port = 9031
      healthcheck_path = "/"
    }
    "solr" = {
      port = 8983
      healthcheck_path = "/solr/#/"
    }
    "scigraph-data" = {
      port = 9000
      healthcheck_path = "/scigraph/docs/"
    }
    "scigraph-ontology" = {
      port = 9090
      healthcheck_path = "/scigraph/docs/"
    }
  }
}

variable "manager_name" {
  default = "tf-monarch-manager"
}

variable "virtual_machines" {
  default = {
    tf-monarch-manager = { 
      machine_type = "e2-small"
      role = "manager"
      services = []
    }

    tf-monarch-owlsim = { 
      machine_type = "e2-highmem-8"
      role = "worker"
      services = ["owlsim"]
    }

    tf-monarch-scigraph = { 
      machine_type = "e2-highmem-2"
      role = "worker"
      services = ["scigraph-data", "scigraph-ontology"]
    }

    tf-monarch-solr = { 
      machine_type = "e2-standard-4"
      role = "worker"
      services = ["solr", "biolink"]
    }
  }
}
