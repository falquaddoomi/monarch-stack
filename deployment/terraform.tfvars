# basic GCP values
project = "monarch-initiative"
region = "us-central1"
zone = "us-central1-a"

# path to a credentials file (relative to ./terraform) whose associated account
# has permission to create, view, and destroy cloud resources (the basic
# 'editor' role should suffice)
# (*you must set this value before attempting any terraform operations*)
credentials_file = null

# the ID (email or unique ID) of an existing service account (SA) the VMs in the
# swarm will run as this SA
# (*you must set this value before attempting any terraform operations*)
svc_account_id = null

# resources will be prefixed with this prefix
prefix = "tf-monarch-"

# add VMs that will run services here.
# - the "role" identifies whether it will be used as a docker swarm manager
#   or joined to an existing swarm as a worker node.
#   (must be one of 'manager' or 'worker')
# - the "services" list is passed along to ansible, which then assigns a
#   docker swarm label to the node based on its services.
#   the docker swarm node labels are used in the root
#   docker-compose.yml to schedule containers to run on specific nodes.
#   the list is also saved to the VM metadata for reference.
#   (defaults to an empty list, i.e. [])
# - other available VM customization fields:
#   * machine_type: the type of instance, from GCP's set of machine types
#   * disk_size_gb: the size of the disk in gigabytes (default: 10)
#   * disk_type: the type of disk (default: 'pd-balanced')
# NOTES:
# - at least one instance in the 'manager' role is required
# - machines will be named with the prefix and the key
#   below, e.g. the manager with default values would be tf-monarch-manager
virtual_machines = {
    manager = { 
        machine_type = "e2-small"
        role = "manager"
        services = []
    }

    owlsim = { 
        machine_type = "e2-highmem-8"
        role = "worker"
        services = ["owlsim"]
        disk_size_gb = 20
    }

    scigraph = { 
        machine_type = "e2-highmem-4"
        role = "worker"
        services = ["scigraph-data", "scigraph-ontology"]
        disk_size_gb = 125 # 107GB in /srv/monarch, 111GB total
        disk_type = "pd-standard"
    }

    solr = { 
        machine_type = "e2-standard-4"
        role = "worker"
        services = ["solr", "biolink", "ui"]
        disk_size_gb = 250 # 223GB in /srv/monarch, 228GB total
        disk_type = "pd-standard"
    }
}
