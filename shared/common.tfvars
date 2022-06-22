# ---------------------------------------------------------------------------------------------------
# --- general google cloud inputs
# ---------------------------------------------------------------------------------------------------

"project" = "monarch-initiative"
"region" = "us-central1"
"zone" = "us-central1-a"
"credentials_file" = ".secrets/monarch-initiative-a9a59050572d.json"

# ---------------------------------------------------------------------------------------------------
# --- stack-specific inputs
# ---------------------------------------------------------------------------------------------------

"base_domain" = "monarchinitiative.org"
"prefix" = "tf-monarch-"

"services" = {
    "biolink" = {
        port = 5000
        healthcheck_path = "/"
    }
    "owlsim" = {
        port = 9031
        healthcheck_path = "/"
    }
    "solr" = {
        port = 8983
        healthcheck_path = "/solr/#/"
    }
    "scigraph-data" = {
        port = 9000
        healthcheck_path = "/scigraph/docs/"
    }
    "scigraph-ontology" = {
        port = 9090
        healthcheck_path = "/scigraph/docs/"
    }
}

"manager_name" = "manager"

"service_disks" = {
    "owlsim" = { 
        target = "fetch_owlsim"
        folder = "owlsim"
        disk_size_gb = 20
        scratch_size_gb = 20
    }

    "scigraph-data" = {
        target = "fetch_scigraph_data"
        folder = "scigraph-data"
        disk_size_gb = 90
        scratch_size_gb = 20
        disk_type = "pd-standard"
    }

    "scigraph-ontology" = {
        target = "fetch_scigraph_ontology"
        folder = "scigraph-ontology"
        disk_size_gb = 6
        scratch_size_gb = 1
        disk_type = "pd-standard"
    }

    "solr" = { 
        target = "fetch_solr"
        folder = "solr"
        disk_size_gb = 160 # 223GB in /srv/monarch, 228GB total
        scratch_size_gb = 80
        disk_type = "pd-standard"
    }

    "ui" = {
        target = "fetch_ui"
        folder = "monarch-ui"
        disk_size_gb = 1 # 223GB in /srv/monarch, 228GB total
        disk_type = "pd-standard"
    }
}


"virtual_machines" = {
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

