variable "prefix" {
    type = string
    default = ""
    description = "A string to prefix most resource names, for organization"
}
variable "project" {
    type = string
    description = "The unique GCP project id"
}
variable "zone" {
    type = string
    description = "The GCP compute zone in which to create resources, e.g. us-central1-a"
}
variable "base_domain" {
    type = string
    description = "The base hostname, e.g. monarchinitiative.org"
}
variable "manager_name" {
    type = string
    default = "manager"
    description = "The name of the manager instance, without the prefix"
}

variable "virtual_machines" {
    type = map(object({
        machine_type = string
        role = string
        services = list
    }))
    description = "A dict of entries that describe the VMs to create and which services should be mapped to them"
}
variable "services" {
    type = map(object({
        port = number
        healthcheck_path = string
    }))
    description = "A dict of services and associated metadata, e.g. port number and healthcheck paths"
}