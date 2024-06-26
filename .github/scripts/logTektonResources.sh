#!/usr/bin/env bash

echo "#########################################"
echo "Get Tekton pipeline ..."
echo "#########################################"
kubectl get pipeline -A --ignore-not-found

echo "#########################################"
echo "Get Tekton pipelineruns ..."
echo "#########################################"
kubectl get pipelineruns -A --ignore-not-found

echo "#########################################"
echo "Get Tekton taskruns ..."
echo "#########################################"
kubectl get taskruns -A --ignore-not-found