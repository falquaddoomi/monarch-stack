#!/usr/bin/env bash

function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

DO_DELETE=0
NO_TF=0
NO_ANSIBLE=0
NO_CLEANUP=0
AUTO_APPROVE=""

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h|--help)
      echo "Usage: $0 [-d|--delete] [-a|--approve] [-n|--no-tf] <REST>"
      exit 0
      ;;
    -d|--delete)
      DO_DELETE="1"
      shift # past argument
      ;;
    -a|--approve)
      AUTO_APPROVE="-auto-approve"
      shift # past argument
      ;;
    -n|--no-tf) # skip anything tf-related
      NO_TF="1"
      shift
      ;;
    -na|--no-ansible) # skip anything ansible-related
      NO_ANSIBLE="1"
      shift
      ;;
    -nc|--no-cleanup) # skip destroying populator VM, network after
      NO_CLEANUP="1"
      shift
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

START_TIME=$SECONDS

echo "* Provisioning starting at $( date )..."
(
  [[ ${NO_TF} == "1" ]] || (
      cd terraform
      ( [[ ${DO_DELETE} != "1" ]] || terraform destroy ${AUTO_APPROVE} ) \
       && terraform apply ${AUTO_APPROVE}
  )
) && (
  [[ ${NO_ANSIBLE} == "1" ]] || (
    ./ansible_on_tfinv.sh ansible/run_makefile.yml
  )
) && (
  ELAPSED_TIME=$(($SECONDS - $START_TIME))
  echo "* Provisioning complete at $( date )! Runtime: $( displaytime ${ELAPSED_TIME} )"
)

# despite exit status, attempt to destroy the populator and the network
# (but, critically, not the disks)
[[ ${NO_CLEANUP} == "1" ]] || (
  cd terraform
  terraform destroy ${AUTO_APPROVE} \
    -target google_compute_instance.populator \
    -target google_compute_network.populator_network
)
