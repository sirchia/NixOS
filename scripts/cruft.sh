#!/usr/bin/env bash
# fs-diff.sh
echo "Script to list all the non-persistent cruft"
echo "Written to root since the last boot"
[ "$(id -u)" != 0 ] && exec sudo "$0"

set -euo pipefail

for path in $(zfs diff rootpool/local/root@blank | cut -f2 | sort -u) ; do
  if [ -L "$path" ]; then
    : # The path is a symbolic link, so is probably handled by NixOS already
  elif [ -d "$path" ]; then
    : # The path is a directory, ignore
  elif [ -e "/persist$path" ]; then
    : # The path is already persisted ignore
  else
    echo "$path"
  fi
done

