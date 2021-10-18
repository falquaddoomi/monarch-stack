#!/usr/bin/env bash

_ANSIBLE_CMD=${ANSIBLE_CMD:-ansible-playbook}

# disable host checking (fixme)
export ANSIBLE_SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null"
export ANSIBLE_STDOUT_CALLBACK=debug

# ansible vault notes:
# to use the vault, you must add the following when invoking ansible-playbook:
#   --extra-vars @vaultfile.yml.enc --vault-password-file
# to edit the vault file, use the following command:
#   ansible-vault edit --vault-password-file .secrets/vault-pass vaultfile.yml

./tf_to_inv.sh > ansible/hosts.json && \
    ${_ANSIBLE_CMD} -i ansible/hosts.json "$@"
