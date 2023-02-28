# monarch-stack

This repo contains tooling to provision and deploy the Monarch stack.

The stack relies on [Terraform](https://www.terraform.io/) to provision cloud
resources, currently on Google Cloud (aka "GCP"). Once Terraform has provisoned
virtual machines ("VMs" or "nodes") to run the services,
[Ansible](https://www.ansible.com/) is then used to install Docker on each VM,
then join the VMs to a [Docker Swarm](https://docs.docker.com/engine/swarm/).
Swarm is used to schedule the containers that make up the Monarch stack on each
VM. Services that share data are scheduled on the same VM, as are services that
are too small on their own to warrant their own VM.

You can run these provisioning scripts from wherever you like, be it your local
machine or a 

## Prerequisites

You must have Terraform and Ansible installed, and you'll likely also need
Python, as Ansible depends on it.

You may want to install Docker Desktop if you want to run the stack locally. You
may also want to have the gcloud cli installed if you want to manipulate GCP
resources without having to go through Terraform.

- [Terraform installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Ansible installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Docker Desktop installation](https://docs.docker.com/desktop/) (expand
  "Install Docker Desktop" in the topic browser, then select the subtopic for
  your platform)
- [gcloud CLI installation](https://cloud.google.com/sdk/docs/install)

## Initialization

First, enter `/deployment/terraform/` and run `terraform init`, which will
download the GCP terraform provider among other setup functions.

Next, you'll need to obtain a service account keyfile, which will allow
Terraform to manage GCP resources on your behalf; see `/.secrets/README.md` for
information on how to obtain the keyfile and modify the Terraform config to use
the keyfile.

## Configuration

There are three places where you'll likely be making changes to customize the
stack:
- `deployment/terraform.tfvars`: a terraform file of variable definitions that
  specifies, among other things, the prefix for the stack you're setting up,
  and the VMs along with their metadata (e.g., the type of VM, like “e2-small”,
  its boot disk size, its role — worker or manager, and its services as a list
  of strings). Note that these variables can be overridden by environment
  variables, if you find that more convenient; see the following for details:
  [Input Variables: Environment
  Variables](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables)
- `stack/Makefile`: a Makefile that gets executed on each VM. Currently,
  services are mapped to targets in this Makefile in the file
  `deployment/ansible/setup_stack_app.yml`. Search for where the dict variable
  `service_to_maketarget` is specified, then add your service name as the key
   and the target as the value. Ostensibly, the target fetches data that the
   service depends on before it can start; for example, `fetch_solr` downloads
   and unpacks a database that Solr uses to initialize itself at first run.
- `stack/docker-compose.yml`: a docker compose file where you specify the
  containers you want to run and how they’ll be mapped to VMs


### How Resource Prefixes Are Derived

In order to keep resources created by this stack from clashing with existing
resources, a prefix is used to implicitly namespace the resources on Google
Cloud. The Terraform variable `prefix` is used to set this value. The prefix is
prepended as-is, so it's recommended to put a delimiter, e.g. "-", at the end of
the name. For example, if prefix was `tf-monarch-` (the default value), the
manager VM, whose name is `manager`, would be named `tf-monarch-manager`.

## Usage

To set up the service VMs, enter `deployment` and run the script
`./provision.sh`. Execution will roughly follow this process:

1. First, terraform will run, and will compare the desired resources to what's
currently deployed; if this is the first time running the script, you'll only
see additions, but if you've run it before you might also see removals or
changes if you've changed your terraform config since the last time you ran it.
You'll be asked for your approval, and must explicitly answer `yes` for
resources to be provisioned.

2. Once terraform has set up cloud resources, Ansible will run using terraform's
output to populate its inventory of virtual machines. Ansible will set up each
node to run Docker, including Docker Swarm, and will peform role-specific setup
on each VM. For example, the VM designated as the manager will start the swarm,
and nodes designated as workers will join it.

3. Once all the prerequisities are set up on the nodes, the Monarch stack will
be deployed to the swarm using the `docker-compose.yml` file in `stack`.
