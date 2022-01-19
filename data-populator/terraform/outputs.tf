output "disk_devices" {
    value = {for x in google_compute_disk.disks : x.name => x.self_link}
}
