# ---------------------------------------------------------------------------------------------------
# --- network/firewall config
# ---------------------------------------------------------------------------------------------------

resource "google_compute_network" "monarch_network" {
  name = "monarch-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "monarch_subnetwork" {
  name = "monarch-subnetwork"
  ip_cidr_range = "10.128.0.0/9"
  region        = "us-central1"
  network       = google_compute_network.monarch_network.id
}

resource "google_compute_firewall" "monarch_fw" {
  name    = "monarch-fw-allow-ssh"
  network = google_compute_network.monarch_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "monarch_fw_local" {
  name    = "monarch-fw-allow-local"
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
  name    = "monarch-fw-allow-app"
  network = google_compute_network.monarch_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http-server"]
}

resource "google_compute_firewall" "monarch_fw_app_ssl" {
  name    = "monarch-fw-allow-app-ssl"
  network = google_compute_network.monarch_network.id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["https-server"]
}
