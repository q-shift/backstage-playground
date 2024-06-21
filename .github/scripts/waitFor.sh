#!/usr/bin/env bash
# usage:
# ./waitFor.sh joke operators Succeeded
# ./waitFor.sh pod operators Running "name -o jsonpath='{.status.phase}'"

RESOURCE="${1}"
NAME="${2}"
KUBE_NAMESPACE="${3}"
EXPECTED="${4}"
EXTRA="${5-}"

retries=10
until [[ $retries == 0 ]]; do
  actual=$(kubectl get $RESOURCE $NAME -n $KUBE_NAMESPACE $EXTRA 2>/dev/null || echo "Waiting for $RESOURCE/$NAME in namespace $KUBE_NAMESPACE -> $EXPECTED to appear")
  if [[ "$actual" =~ .*"$EXPECTED".* ]]; then
    echo "Resource \"$RESOURCE/$NAME\" found" 2>&1
    echo "$actual" 2>&1
    break
  else
    echo "Waiting for resource \"$RESOURCE/$NAME\" in namespace $KUBE_NAMESPACE ..." 2>&1
    echo "$actual" 2>&1
  fi
  sleep 15s
  retries=$((retries - 1))
done

# echo "#########################################"
# echo "Describe resource: $RESOURCE $NAME in namespace $KUBE_NAMESPACE"
# echo "#########################################"
# kubectl describe $RESOURCE $NAME -n $KUBE_NAMESPACE 2>&1

# echo "#########################################"
# echo "Resource YAML: $NAME in namespace $KUBE_NAMESPACE"
# echo "#########################################"
# kubectl get $RESOURCE $NAME -n $KUBE_NAMESPACE -o yaml