#!/usr/bin/env bash

REPO_NAME="${1}"
SUFFIX="${2}"
NAMESPACE="${3}"

echo "#########################################"
echo "Failed to get application $REPO_NAME-$SUFFIX Synced in namespace: $NAMESPACE"

echo "#########################################"
echo "Describe Application: $REPO_NAME-$SUFFIX in namespace: $NAMESPACE"
echo "#########################################"
kubectl describe application $REPO_NAME-$SUFFIX -n $NAMESPACE

echo "#########################################"
echo "Application YAML: $REPO_NAME-$SUFFIX in namespace: $NAMESPACE"
echo "#########################################"
kubectl get application $REPO_NAME-$SUFFIX -n $NAMESPACE -o yaml