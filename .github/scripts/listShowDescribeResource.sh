#!/usr/bin/env bash

RESOURCE="${1}"
NAMESPACE="${2}"

echo "#########################################"
echo "List $RESOURCE in namespace: $NAMESPACE"
echo "#########################################"
kubectl get $RESOURCE -n $NAMESPACE

echo "#########################################"
echo "Describe $RESOURCE in namespace: $NAMESPACE"
echo "#########################################"
kubectl describe $RESOURCE -n $NAMESPACE

echo "#########################################"
echo "Show $RESOURCE YAML: $NAME in namespace: $NAMESPACE"
echo "#########################################"
kubectl get $RESOURCE -n $NAMESPACE -o yaml