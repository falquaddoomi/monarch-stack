# ---------------------------------------------------------------------------------------------------
# --- backend service config
# ---------------------------------------------------------------------------------------------------

# background:
# ----
# * a network endpoint group (NEG) associates a service with a set of endpoints (typically VMs)
# * an endpoint is a mapping of a NEG to a ip/port combination
# typically a NEG has a single port, but it's possible that the same service could be addressed
# using different ports on different VMs.
# in our case, we use NEGs to point the load balancer's backends at one or more VMs, on a
# per-service basis.

locals {
  services_machines = flatten([
    for vk, vm in var.virtual_machines : [
      for k, v in var.services : { machine = vk, service = k, port = v.port }
      if contains(var.virtual_machines[vk].services, k)
    ]
  ])
}

resource "google_compute_network_endpoint_group" "negs" {
  for_each = var.services

  name         = "${each.key}-neg"
  network      = google_compute_network.monarch_network.id
  subnetwork   = google_compute_subnetwork.monarch_subnetwork.id
  default_port = each.value.port
  zone         = var.zone

  lifecycle {
    create_before_destroy = true
  }
}

// the same VM may host multiple services, thus it might be in multiple NEGs and might have multiple endpoints associated with it
resource "google_compute_network_endpoint" "endpoints" {
  for_each = {for v in local.services_machines : "${v.service}-${v.machine}" => v}

  network_endpoint_group = google_compute_network_endpoint_group.negs[each.value.service].name

  instance   = google_compute_instance.nodes[each.value.machine].name
  port       = each.value.port
  ip_address = google_compute_instance.nodes[each.value.machine].network_interface[0].network_ip
}
