#!/bin/bash

IP_FILE="$1"
POWER=${2}

IPS=()

while IFS='' read -r line || [[ -n "${line}" ]]; do
    IPS+=(${line})
done < "${IP_FILE}"

for IP in "${IPS[@]}"
do
    sshpass -p root ssh -o StrictHostKeyChecking=no -t root@${IP} ash -c "'
        rm -rf /tmp/restore
        mkdir -p /tmp/restore
        tar zxf restore.tgz -C /tmp/restore

        num_rad=\$(uci -c /tmp/restore/etc/config show wireless | grep wifi-device | wc -l)
        num_rad=\$((\${num_rad} - 1))

        for nrad in \$(seq 0 \${num_rad})
        do
            echo \"Set radio\${nrad} to txpower ${POWER}\"
            uci -c /tmp/restore/etc/config set wireless.@wifi-device[\${nrad}].txpower=${POWER}
            uci -c /tmp/restore/etc/config commit
        done

        for nrad in \$(seq 0 \${num_rad})
        do
            uci set wireless.@wifi-device[\${nrad}].txpower=${POWER}
            uci commit
        done

        tar zcf restore.tgz -C /tmp/restore ./
        wifi
    '"
done