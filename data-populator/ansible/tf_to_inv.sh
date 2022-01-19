#!/bin/bash

# saw the --list flag
SAW_LIST=0
# saw the --host flag
SAW_HOST=0
HOST_SEEN="" # the host that came after --host
# remaining arguments
REST=()

# loop through args, stripping out flags and concating the rest to REST
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --list)
      SAW_LIST=1
      shift
      ;;
    --host)
      SAW_HOST=1
      shift
      HOST_SEEN="$1"
      shift
      ;;
    *)
      REST+=("$1")
      shift
      ;;
  esac
done

read -r -d '' TF_FILTER <<EOF
# extract hosts and outputs from the tfstate file
{
    hosts: [.resources |
        map(select(.type == "google_compute_instance")) |
        .[].instances | .[] | {
            name: .attributes.name,
            ip: .attributes.network_interface[].access_config[].nat_ip,
            services: (
                if .attributes.metadata | has("services")
                then .attributes.metadata.services | fromjson
                else [] end
            ),
            service_disks: (
                if .attributes.metadata | has("service_disks")
                then .attributes.metadata.service_disks | fromjson
                else [] end
            ),
            targets: (
                if .attributes.metadata | has("targets")
                then .attributes.metadata.targets | fromjson
                else [] end
            )
        }
    ],
    outputs: .outputs
} |
# shape the output to look like an ansible inventory
{
    all: {
        hosts: [ .hosts | .[] | .name ],
        vars: {
            ansible_python_interpreter: "/usr/bin/python3",
            outputs: .outputs | to_entries | map({(.key): .value.value}) | add
        }
    },
    _meta: {
        hostvars: [ .hosts | .[] | {(.name): {
            ansible_host: .ip,
            ansible_python_interpreter: "/usr/bin/python3",
            vars: {
                services: .services,
                service_disks: .service_disks,
                targets: .targets
            }
        }} ] | add
    }
}
EOF

TARGET_FILE=${REST[0]:-__tf_state_pull__}

# if a URL was specified, curl and pipe that into jq
# otherwise, get it from the local filesystem
if [[ "$TARGET_FILE" =~ ^http.* ]]; then
    curl -s "${TARGET_FILE}" | jq "${TF_FILTER}"
elif [[ "$TARGET_FILE" == "__tf_state_pull__" ]]; then
    export SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    (
        cd "${SCRIPT_DIR}/../terraform"
        terraform state pull
    ) | jq "${TF_FILTER}"
else
    jq "${TF_FILTER}" ${TARGET_FILE}
fi
