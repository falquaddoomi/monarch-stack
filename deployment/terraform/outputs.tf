output "ipv6_cidr_range" {
    value = google_compute_subnetwork.monarch_subnetwork.ipv6_cidr_range
}

output "internal_ipv6_range" {
    value = google_compute_network.monarch_network.internal_ipv6_range
}
