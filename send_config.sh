#!/bin/bash

IP_FILE="$1"

IPS=()

while IFS='' read -r line || [[ -n "${line}" ]]; do
    IPS+=(${line})
done < "${IP_FILE}"

for IP in "${IPS[@]}"
do
    sshpass -p pepe ssh -o StrictHostKeyChecking=no -t jose@${IP} bash -c "'
        . /lib/functions.sh

        handle_interface() {
            local config=\"$1\"
            local custom=\"$2\"
            # run commands for every interface section
            config_get iface \"$config\" ifname
            config_set \"$config\" auto 0
        }

        cd /root
        tar zxvf restore.tgz

        config_load network
        config_foreach handle_interface interface test
    '"
done