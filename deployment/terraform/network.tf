# ---------------------------------------------------------------------------------------------------
# --- network/firewall config
# ---------------------------------------------------------------------------------------------------

resource "google_compute_network" "monarch_network" {
  name = "${var.prefix}network"
  auto_create_subnetworks = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "monarch_subnetwork" {
  name = "${var.prefix}subnetwork"
  ip_cidr_range = "10.128.0.0/9"
  region        = "us-central1"
  network       = google_compute_network.monarch_network.id

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL"
}

resource "google_compute_firewall" "monarch_fw" {
  name    = "${var.prefix}fw-allow-ssh"
  network = google_compute_network.monarch_network.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "monarch_fw_local" {
  name    = "${var.prefix}fw-allow-local"
  network = google_compute_network.monarch_network.id

  source_ranges = [
    google_compute_subnetwork.monarch_subnetwork.ip_cidr_range
  ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "monarch_fw_app" {
  name    = "${var.prefix}fw-allow-app"
  network = google_compute_network.monarch_network.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http-server"]
}

resource "google_compute_firewall" "monarch_fw_app_ssl" {
  name    = "${var.prefix}fw-allow-app-ssl"
  network = google_compute_network.monarch_network.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["https-server"]
}
