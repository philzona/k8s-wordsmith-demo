#!/bin/bash

export HTTP_PASS

echo "Getting external IP address for web service..."
external_ip=$(kubectl get svc -n $NS | grep web | awk '{print $4}')
echo "External IP: $external_ip"

count=0
# Retry until the service has not been fully provisioned or for 2 minutes
while [ $external_ip = '<pending>' ]; do
    sleep 5
    external_ip=$(kubectl get svc -n $NS | grep web | awk '{print $4}')
    echo "External IP: $external_ip"
    count=$((count + 1))

    if [ $count -ge 24 ]; then
        echo "No response after 2 minutes, something is probably wrong"
        exit 1
    fi;
done;

echo "Getting port..."
port_string=$(kubectl get svc -n $NS | grep web | awk '{print $5}')
port=$(echo $port_string | cut -d ":" -f 1)

echo "Checking connectivity..."
status=$(curl -sL -o /dev/null -w "%{http_code}" "http://${external_ip}:${port}")

if [ $status -eq 200 ]; then
    HTTP_PASS="true"
else
    HTTP_PASS="false"
fi;

echo "External IP: $external_ip"
echo "Port: $port"
echo "Request status: $status"
echo "Review URL: http://${external_ip}:${port}"

echo "Test passed: $HTTP_PASS"

cf_export HTTP_PASS

if [ $HTTP_PASS = "true" ]; then
    exit 0
else
    exit 1
fi;