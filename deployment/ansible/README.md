# Ansible Monarch Setup

This folder contains Ansible configuration, helper scripts, and playbooks. Ansible playbooks should typically be run using the entrypoint script at  `../ansible_on_tfinv.sh`, which connects Ansible to Terraform and sets up other config variables.


## Playbooks

The playbooks implement the following tasks:
1. Orchestrate full deployment (by running `./setup_swarm.yml`)
   - this is the entrypoint playbook, which invokes the other playbooks references below.
2. Installing docker on each host in the cluster (via importing `./support/setup_docker.yml`)
3. Creating the swarm (back in `./setup_swarm.yml`):
    - creates the swarm on the manager node
    - assigns the manager node to the swarm manager role
    - has worker nodes join the swarm, using the join token generated on the manager
4. Assigns roles (specified in terraform) to each node
    - these are used when deploying the monarch stack to the swarm, to place services on specific nodes. (see `<ROOT>/stack/docker-compose.yml`, specifically `.deploy.placement.constraints` on each service definition for details.)
5. Deploying the monarch app to the swarm (via importing `./setup_monarch_app.yml`)
    - installs dependencies for the deployment process (rsync, jsondiff, pyyaml)
    - copies `<ROOT>/stack` to each host (at `/stack` on the host), since it contains config for multiple hosts
    - puts the current user in the `docker` group on each host
    - syncs letsencrypt certs to the manager node, for the SSL terminating balancer
    - creates a Docker registry service on the swarm for hosting custom images
    - builds the `<ROOT>/stack/docker-images/balancer` image, then pushes it to the registry
    - deploys the monarch stack to the swarm using `<ROOT>/stack/docker-compose.yml`


## Helper Scripts

### Ansible Inventory Generation

The helper script `tf_to_inv.sh` mediates the connection between Terraform and Ansible, specifically by reading Terraform's statefile (including TF module outputs) and making them available to Ansible as an inventory of hosts and associated variables. The script implements Ansible's [dynamic inventory script interface](https://docs.ansible.com/ansible/latest/dev_guide/developing_inventory.html#developing-inventory-scripts).

While the script takes the standard `--list` and `--host` arguments required by the dynamic inventory specification, it also takes an optional positional argument that indicates how to access Terraform's state.

### VM Initial Setup
The setup script `./init_scripts/startup_vm_lite.sh` is deployed to each host and executed at boot to set up Google Cloud resource monitoring, fix locale issues, and generally track the startup process. When it's done, the script writes the current datetime to `/etc/startup_was_launched`, which  `./setup_swarm.yml` looks for to identify that the host is ready for further provisioning. The setup script will immediately exit if `/etc/startup_was_launched` already exists.

## Configuration and Support

The file `ansible.cfg` is explicity included by the Ansible entrypoint script `../ansible_on_tfinv.sh` and contains settings that mostly control Ansible's output on the deploying host.

There are a number of playbooks that aren't included by `./setup_swarm.yml`, but can be useful for debugging.