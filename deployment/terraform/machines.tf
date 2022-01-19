# ---------------------------------------------------------------------------------------------------
# --- VM config
# ---------------------------------------------------------------------------------------------------

# data "template_file" "default" {
#   template = file("./scripts/startup_vm.sh")
# }

variable "node_image" {
  // default = "debian-10-docker-v1"
  default = "debian-cloud/debian-10"
  // default = "projects/cos-cloud/global/images/cos-dev-97-16678-0-0"
  // default = "fedora-coreos-cloud/fedora-coreos-34-20210904-2-0-gcp-x86-64"
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
      # startup-script = "${data.template_file.default.rendered}"
      # enable-oslogin = true
      role = each.value.role
      services = jsonencode(try(each.value.services, []))
  }

  network_interface {
    network = google_compute_network.monarch_network.id
    subnetwork   = google_compute_subnetwork.monarch_subnetwork.id
    access_config { }
  }
}

# produces a list of machine-to-service mappings for attaching service disks
locals {
  services_disks = flatten([
    for vk, vm in var.virtual_machines : [
      for svc in vm.services : { machine = vk, service = svc }
      if contains(["owlsim", "scigraph-data", "scigraph-ontology", "solr", "ui"], svc)
    ]
  ])
}

# attaches disks to whichever machines requested them
resource "google_compute_attached_disk" "disk-attachments" {
  for_each = {for v in local.services_disks : "${v.service}-${v.machine}" => v}

  disk     = "${var.prefix}${each.value.service}-servicedisk"
  instance = "${var.prefix}${each.value.machine}"
  device_name = "${each.value.service}"
}
