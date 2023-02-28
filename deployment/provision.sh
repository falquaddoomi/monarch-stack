#!/usr/bin/env bash

export ANSIBLE_PLAYBOOK=${ANSIBLE_PLAYBOOK:-ansible/setup_swarm.yml}
export INVENTORY=${INVENTORY:-./ansible/tf_to_inv.sh}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

DO_DESTROY=0
DO_APPLY=1
NO_TF=0
NO_ANSIBLE=0
AUTO_APPROVE=""

function exit_w_msg {
  echo "$1"
  exit ${2:-1}
}

# we need to be in the script dir for relative references to work, so let's
# just cd there
cd $SCRIPT_DIR

# text that's displayed when the user requests help
mapfile -d '' HELP_TEXT << EOF
Usage: $0 [-d|--destroy] [-a|--approve] [-na|--no-apply] [-n|--no-tf] <REST>
  -d |--destroy    destroys any existing terraform infrastructure
  -x |--approve    automatically approves any terraform confirmation requests
  -na|--no-apply   skips the terraform apply step
  -n |--no-tf      skips terraform entirely
  <REST>           arguments are passed to ansible-playbook as-is

Description:
  This script is used to deploy the monarch stack to 
  Google Cloud, using terraform to set up infrastructure and ansible
  to configure the deployed instance(s).
  
  The script first runs the contents of ./terraform as a module, then
  runs an ansible playbook (default: ansible/setup_swarm.yml) to set up
  the resources created by terraform. The ansible playbook is passed
  an inventory built from the terraform VMs specified in ./terraform/machines.tf
  and grouped by the 'role' attribute.

Usage Notes:
  The default is to perform a terraform apply and then run ansible. If
  -d is specified, a destroy will occur before the apply, ensuring that
  all the resources used are new. To destroy and not reapply (if you're
  shutting down the service for a while, for example), use -d and -na
  to destroy and skip the apply. If ansible is invoked without anything
  in the inventory it will also be skipped, which is the case when all
  the cloud resources are destroyed without being applied (e.g., -d -na).

EOF

# # if no arguments were specified at all, just treat it as a request for help
# if [[ $# -eq 0 ]]; then
#   set -- "-h"
# fi

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h|--help)
      echo -n "${HELP_TEXT}"
      exit 0
      ;;
    -d|--destroy)
      DO_DESTROY="1"
      shift
      ;;
    -x|--approve)
      AUTO_APPROVE="-auto-approve"
      shift
      ;;
    -a|--apply)
      DO_APPLY=1
      shift
      ;;
    -na|--no-apply)
      DO_APPLY=0
      shift
      ;;
    -n|--no-tf) # skip anything tf-related
      NO_TF="1"
      shift
      ;;
    -nx|--no-ansible)
      NO_ANSIBLE=1
      shift
      ;;
    *)
      # unknown option, pass it on to ansible
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# load in terraform vars from the terraform.tfvars file in this folder
VAR_FILE_DEFN="-var-file $( realpath ./terraform.tfvars )"

(
  [[ ${NO_TF} == "1" ]] || (
      cd terraform
      ( [[ ${DO_DESTROY} != "1" ]] || terraform destroy ${AUTO_APPROVE} ${VAR_FILE_DEFN} ) \
       && \
      ( [[ ${DO_APPLY} != "1" ]] || terraform apply ${AUTO_APPROVE} ${VAR_FILE_DEFN} ) \
  )
) && (
  ! ${INVENTORY} >/dev/null 2>&1 \
    && exit_w_msg "* inventory has nonzero exit status (empty?), aborting" \
    || (
      [[ ${NO_ANSIBLE} == "1" ]] ||  \
      ./ansible_on_tfinv.sh ${ANSIBLE_PLAYBOOK} "${POSITIONAL[@]}"
    )
)
