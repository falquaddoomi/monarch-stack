# ---------------------------------------------------------------------------------------------------
# --- VM config
# ---------------------------------------------------------------------------------------------------

# create disks for each service
resource "google_compute_disk" "disks" {
  for_each = var.service_disks

  name = "${var.prefix}${each.key}-servicedisk"
  description = "Disk for the ${each.key} service"
  size = each.value.disk_size_gb
  type = try(each.value.disk_type, "pd-balanced")
}

resource "google_compute_attached_disk" "disk-attachments" {
  for_each = var.service_disks

  disk     = google_compute_disk.disks[each.key].id
  instance = google_compute_instance.populator.id
  device_name = "${each.key}"
}

resource "google_compute_instance" "populator" {
  name         = "${var.prefix}populator"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
      size = 10 + sum([for x in var.service_disks : try(x.scratch_size_gb, 0) ])
      type = "pd-balanced"
    }
  }

  lifecycle { ignore_changes = [attached_disk] }

  metadata = {
      # startup-script = "${data.template_file.default.rendered}"
      # enable-oslogin = true
      services = jsonencode(keys(var.service_disks))
      service_disks = jsonencode(var.service_disks)
      targets = jsonencode(flatten([for x in var.service_disks : x.target ]))
  }

  network_interface {
    network = google_compute_network.populator_network.id
    subnetwork   = google_compute_subnetwork.populator_subnetwork.id
    access_config { }
  }
}
