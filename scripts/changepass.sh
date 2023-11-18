#!/bin/sh
# read password twice
USERNAME=${1:-user}
PASSWORD_PATH=${2:-/persist/passwords}
PASSWORD_FILE=${PASSWORD_PATH}/${USERNAME}
read -s -p "Enter New Password for user ${USERNAME}: " p1
echo 
read -s -p "Password (again): " p2
echo

if [[ "$p1" != "$p2" ]]; then
  echo "Passwords do not match! Exiting ..."
  exit
elif
  [[ "$p1" == "" ]]; then
  echo "Empty password. Exiting ..."
  exit
fi

mkdir -p ${PASSWORD_PATH}
mkpasswd -m sha-512 "$p1" > ${PASSWORD_FILE}

echo
echo "New password written to ${PASSWORD_FILE}"
echo "Password will become active next time you run:" 
echo "sudo nixos-rebuild switch"

