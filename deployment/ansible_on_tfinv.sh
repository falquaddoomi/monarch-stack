#!/usr/bin/env bash

_ANSIBLE_CMD=${ANSIBLE_CMD:-ansible-playbook}

# disable host checking (fixme)
export ANSIBLE_SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null"
export ANSIBLE_STDOUT_CALLBACK=debug

./tf_to_inv.sh > ansible/hosts.yml && \
    ${_ANSIBLE_CMD} -i ansible/hosts.yml "$@"
