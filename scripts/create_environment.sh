#!usr/bin/env bash

kubectl config use-context gke

if kubectl get ns | grep -q $NS; then
  kubectl delete ns $NS
fi

kubectl create ns $NS
