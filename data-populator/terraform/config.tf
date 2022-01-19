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
      version = "4.5"
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

variable "service_disks" {
  default = {
    "owlsim" = { 
      target = "fetch_owlsim"
      folder = "owlsim"
      disk_size_gb = 20
      scratch_size_gb = 20
    }

    "scigraph-data" = {
      target = "fetch_scigraph_data"
      folder = "scigraph-data"
      disk_size_gb = 90
      scratch_size_gb = 20
      disk_type = "pd-standard"
    }

    "scigraph-ontology" = {
      target = "fetch_scigraph_ontology"
      folder = "scigraph-ontology"
      disk_size_gb = 6
      scratch_size_gb = 1
      disk_type = "pd-standard"
    }

    "solr" = { 
      target = "fetch_solr"
      folder = "solr"
      disk_size_gb = 160 # 223GB in /srv/monarch, 228GB total
      scratch_size_gb = 80
      disk_type = "pd-standard"
    }

    "ui" = {
      target = "fetch_ui"
      folder = "monarch-ui"
      disk_size_gb = 1 # 223GB in /srv/monarch, 228GB total
      disk_type = "pd-standard"
    }
  }
  description = "Dict of disks to disk properties, makefile targets, and resulting folder under DATADIR"
}
