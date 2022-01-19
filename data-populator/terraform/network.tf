# ---------------------------------------------------------------------------------------------------
# --- network/firewall config
# ---------------------------------------------------------------------------------------------------

resource "google_compute_network" "populator_network" {
  name = "monarch-populator-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "populator_subnetwork" {
  name = "monarch-populator-subnetwork"
  ip_cidr_range = "10.128.0.0/9"
  region        = "us-central1"
  network       = google_compute_network.populator_network.id
}

resource "google_compute_firewall" "populator_fw" {
  name    = "monarch-populator-fw-allow-ssh"
  network = google_compute_network.populator_network.id
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
