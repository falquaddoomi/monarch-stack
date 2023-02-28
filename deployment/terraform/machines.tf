# ---------------------------------------------------------------------------------------------------
# --- VM config
# ---------------------------------------------------------------------------------------------------

variable "node_image" {
  default = "debian-cloud/debian-10"
}

// retrieve the ID of the VM service account
data "google_service_account" "vm_svc_acct" {
  account_id   = "${var.svc_account_id}"
}

resource "google_compute_instance" "nodes" {
  for_each = var.virtual_machines

  name         = "${var.prefix}${each.key}"
  machine_type = each.value.machine_type
  # tags = ["http-server"]

  boot_disk {
    initialize_params {
      image = var.node_image
      size = try(each.value.disk_size_gb, 10)
      type = try(each.value.disk_type, "pd-balanced")
    }
  }

  metadata = {
      role = each.value.role
      services = jsonencode(try(each.value.services, []))
  }

  network_interface {
    network = google_compute_network.monarch_network.id
    subnetwork   = google_compute_subnetwork.monarch_subnetwork.id
    stack_type = "IPV4_IPV6"

    access_config { 
      network_tier = "STANDARD"
    }
  }

  service_account {
    email  = data.google_service_account.vm_svc_acct.email
    scopes = ["cloud-platform"]
  }
}
