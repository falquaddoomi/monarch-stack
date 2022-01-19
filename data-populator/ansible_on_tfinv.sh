#!/usr/bin/env bash

_ANSIBLE_CMD=${ANSIBLE_CMD:-ansible-playbook}

# disable host checking (fixme)
export ANSIBLE_SSH_ARGS="-o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null"
export ANSIBLE_CONFIG=ansible/ansible.cfg

# ansible vault notes:
# to use the vault, you must add the following when invoking ansible-playbook:
#   --extra-vars @vaultfile.yml.enc --vault-password-file .secrets/vault-pass
# to edit the vault file, use the following command:
#   ansible-vault edit --vault-password-file .secrets/vault-pass vaultfile.yml

${_ANSIBLE_CMD} -i ./ansible/tf_to_inv.sh "$@"
