# Monarch Load Balancer, Backends

This module contains definitions for the following entities:
1. **Network Endpoint Groups (NEGs)**, one per service, associated with our instances
2. A **load balancer** that directs paths to the NEGs

The module requires that a few stack-specific variables be passed in from the root module, specifically:
- **virtual_machines:** a dictionary of information about each instance and the services mapped to it
- **services:** a dictionary of metadata about the services (their ports, health check info)

The module also requires some variables that describe the GCP project, specifically:
- **prefix:** an optional string that is added as a prefix to most resources
- **project:** the unique GCP project identifier
- **zone:** the GCP compute zone in which the instances are located (e.g., `us-central1-a`)
- **base_domain:** the domain name for the cluster, e.g. `monarchinitiative.org`
- **manager_name:** the name of the manager instance, without the prefix
