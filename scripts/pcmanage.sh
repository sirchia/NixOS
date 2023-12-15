#!/bin/sh

# Change variables here:
APPDATA_LOC="/workload/appdata"

# Don't change variables below unless you want to customize the script
VERSIONS_LOC="$APPDATA_LOC/versions.txt"

function backupVersions {
    > "$VERSIONS_LOC"

    for i in $(podman ps --format '{{.Names}}'); do
        container_name=$i
        image_name=$(podman inspect --format='{{ index .Config.Image }}' "$container_name")
        repo_digest=$(podman inspect --format='{{ index .RepoDigests 0 }}' $(podman inspect --format='{{ .Image }}' "$container_name"))
        echo "$container_name,$image_name,$repo_digest" >> "$VERSIONS_LOC"
    done
}

function update {
    if systemctl list-units | grep "podman.*service" | grep -v -E "podman-network|podman-auto-update|running"; then
      echo "The service(s) listed above were not in a healthy state, canceling update"
      exit 1
    fi

    echo "Backing up version hashes"
    backupVersions

    # echo "Performing dry-run update to see what's changed"
    # for i in $(podman auto-update --dry-run --format "{{.Image}} {{.Updated}}" | grep pending | cut -d " " -f1); do
    #    echo "Updating $i"
    # done
    
    podman auto-update --format "{{.Image}} {{.Updated}}" | grep true
    exit 0
}

function restore {
    if [ "$1" = "" ]; then
      echo "provide the service name to restore"
      exit 1
    fi
    
    image_name=$(grep "^$1," "$VERSIONS_LOC" | awk -F, '{print $2}')
    repo_digest=$(grep "^$1," "$VERSIONS_LOC" | awk -F, '{print $3}')
    sed -i "s#image = \"${image_name}\"#image = \"${repo_digest}\"#g" /etc/nixos/container-services/*.nix

    nixos-rebuild switch
}

function resume {
    if [ "$1" = "" ]; then
      echo "provide the service name to resume"
      exit 1
    fi
    
    image_name=$(grep "^$1," "$VERSIONS_LOC" | awk -F, '{print $2}')
    repo_digest=$(grep "^$1," "$VERSIONS_LOC" | awk -F, '{print $3}')
    sed -i "s#image = \"${repo_digest}\"#image = \"${image_name}\"#g" /etc/nixos/container-services/*.nix

    nixos-rebuild switch
}


# Check if the function exists
if declare -f "$1" > /dev/null; then
  "$@"
else
  echo "The only valid arguments are backupVersions update, restore X, and resume X"

  exit 1
fi
