#!/usr/bin/env bash

read -r -d '' TF_FILTER <<EOF
# extract hosts and outputs from the tfstate file
{
    hosts: [.resources |
        map(select(.type == "google_compute_instance")) |
        .[].instances | .[] | {
            name: .attributes.name,
            ip: .attributes.network_interface[].access_config[].nat_ip,
            role: .attributes.metadata.role
        }
    ],
    outputs: .outputs
} |
# shape the output to look like an ansible inventory
{
    all: {
        children: [
            .hosts | group_by(.role) | .[] | {
                (.[0].role): {
                    hosts: map({(.name): {ansible_host: .ip}}) | add
                }
            }
        ] | add,
        vars: {
            ansible_python_interpreter: "/usr/bin/python3",
            outputs: .outputs | to_entries | map({(.key): .value.value}) | add
        }
    }
}
EOF

jq "${TF_FILTER}" ${1:-./terraform/terraform.tfstate}
