#!/usr/bin/env bash

DO_DELETE=0
NO_TF=0
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
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

(
  [[ ${NO_TF} == "1" ]] || (
      cd terraform
      ( [[ ${DO_DELETE} != "1" ]] || terraform destroy ${AUTO_APPROVE} ) \
       && terraform apply ${AUTO_APPROVE}
  )
) && ./ansible_on_tfinv.sh ansible/setup_swarm.yml
