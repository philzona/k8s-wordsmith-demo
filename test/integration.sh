#!/bin/bash

export HTTP_PASS

external_ip=$(kubectl get svc -n $NS | grep web | awk '{print $4}')
port_string=$(kubectl get svc -n $NS | grep web | awk '{print $5}')
port=$(echo $port_string | cut -d ":" -f 1)

status=$(curl -sL -o /dev/null -w "%{http_code}" "http://${external_ip}:${port}")

if [ $status -eq 200 ]; then
    HTTP_PASS="true"
else
    HTTP_PASS="false"
fi;

echo $HTTP_PASS

cf_export HTTP_PASS