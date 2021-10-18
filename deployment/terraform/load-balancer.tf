# ---------------------------------------------------------------------------------------------------
# --- load balancer config
# ---------------------------------------------------------------------------------------------------

resource "google_compute_url_map" "urlmap" {
  name        = "urlmap"
  default_service = module.lb-http.backend_services.biolink.id

  // redirects subdirs of the root domain to backend services
  host_rule {
    hosts        = [var.base_domain]
    path_matcher = "general"
  }
  path_matcher {
    name            = "general"
    default_service = module.lb-http.backend_services.biolink.id

    path_rule {
      paths   = ["/api/*"]
      service = module.lb-http.backend_services.biolink.id
      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }

    path_rule {
      paths   = ["/owlsim/*"]
      service = module.lb-http.backend_services.owlsim.id
      route_action {
        url_rewrite {
          path_prefix_rewrite = "/"
        }
      }
    }
  }

  // direct subdomains to the appropriate backend services
  dynamic "host_rule" {
    for_each = keys(var.services)
    content {
      hosts = ["${host_rule.value}.${var.base_domain}"]
      path_matcher = "${host_rule.value}-paths"
    }
  }
  dynamic "path_matcher" {
    for_each = keys(var.services)
    content {
      name            = "${path_matcher.value}-paths"
      default_service = module.lb-http.backend_services[path_matcher.value].id
    }
  }

  // biolink
  /*
  host_rule {
    hosts = ["api.${var.base_domain}"]
    path_matcher = "biolink-paths"
  }
  path_matcher {
    name            = "biolink-paths"
    default_service = module.lb-http.backend_services["biolink"].id
  }

  // solr
  host_rule {
    hosts = ["solr.${var.base_domain}"]
    path_matcher = "solr-paths"
  }
  path_matcher {
    name            = "solr-paths"
    default_service = module.lb-http.backend_services["solr"].id
  }

  // scigraph-ontology
  host_rule {
    hosts = ["scigraph-ontology.${var.base_domain}"]
    path_matcher = "scigraph-ontology-paths"
  }
  path_matcher {
    name            = "scigraph-ontology-paths"
    default_service = module.lb-http.backend_services["scigraph-ontology"].id
  }

  // scigraph-data
  host_rule {
    hosts = ["scigraph-data.${var.base_domain}"]
    path_matcher = "scigraph-data-paths"
  }
  path_matcher {
    name            = "scigraph-data-paths"
    default_service = module.lb-http.backend_services["scigraph-data"].id
  }
  */
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "6.0.1"

  # config
  name = "monarch-tf-balancer"
  project = var.project

  firewall_networks = [google_compute_network.monarch_network.id]
  create_url_map = false
  url_map = google_compute_url_map.urlmap.id

  ssl = true
  managed_ssl_certificate_domains = [
    "monarch-gc-balanced.ddns.net",
    "api.monarch-gc-balanced.ddns.net",
    "scigraph-data.monarch-gc-balanced.ddns.net",
    "scigraph-ontology.monarch-gc-balanced.ddns.net",
    "solr.monarch-gc-balanced.ddns.net",
  ]

  backends = {
      for service_name, desc in var.services : service_name => {
        "description" = "${service_name} backend"
        "port" = 80
        "port_name" = "http"
        "protocol" = "HTTP"
        "security_policy" = null
        "session_affinity" = null
        "timeout_sec" = 30

        "affinity_cookie_ttl_sec" = null
        "connection_draining_timeout_sec" = null
        "custom_request_headers" = null
        "custom_response_headers" = null

        "enable_cdn" = false
        "groups" = [
          {
            group                        = google_compute_network_endpoint_group.negs["${service_name}"].self_link
            balancing_mode               = "RATE"
            capacity_scaler              = null
            description                  = null
            max_connections              = null
            max_connections_per_instance = null
            max_connections_per_endpoint = null
            max_rate                     = null
            max_rate_per_instance        = null
            max_rate_per_endpoint        = 120
            max_utilization              = null
          }
        ]
        
        "health_check" = {
          check_interval_sec  = 30
          timeout_sec         = 10
          healthy_threshold   = 1
          unhealthy_threshold = 0
          request_path        = desc.healthcheck_path
          port                = desc.port
          host                = google_compute_instance.nodes[var.manager_name].network_interface[0].network_ip
          logging             = false
        }

        iap_config = {
          enable               = false
          oauth2_client_id     = null
          oauth2_client_secret = null
        }

        "log_config" = {
          enable = true
          sample_rate = 1.0
        }
      }
  }
}
