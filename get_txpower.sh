#!/bin/bash

IP_FILE="$1"

IPS=()

while IFS='' read -r line || [[ -n "${line}" ]]; do
    IPS+=(${line})
done < "${IP_FILE}"

for IP in "${IPS[@]}"
do
    sshpass -p root ssh -o StrictHostKeyChecking=no -t root@${IP} ash -c "'iwinfo | grep Tx-Power'"
done
