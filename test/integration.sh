#!/bin/bash

export HTTP_PASS

echo "Getting external IP address for web service..."
external_ip=$(kubectl get svc -n $NS | grep web | awk '{print $4}')

# Retry until the service has not been fully provisioned
while [ $external_ip = '<pending>' ]; do
    echo "External IP: $external_ip"
    sleep 5
    external_ip=$(kubectl get svc -n $NS | grep web | awk '{print $4}')
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

echo "Test passed: $HTTP_PASS"
