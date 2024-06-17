#!/usr/bin/env bash
# usage:
# ./waitFor.sh joke operators Succeeded
# ./waitFor.sh pod operators Running "name -o jsonpath='{.status.phase}'"

RESOURCE="${1}"
NAME="${2}"
NAMESPACE="${3}"
EXPECTED="${4}"
EXTRA="${5-}"

retries=30
until [[ $retries == 0 ]]; do
  actual=$(kubectl get $RESOURCE $NAME -n $NAMESPACE $EXTRA 2>/dev/null || echo "Waiting for $RESOURCE/$NAME -> $EXPECTED to appear")
  if [[ "$actual" =~ .*"$EXPECTED".* ]]; then
    echo "Resource \"$RESOURCE/$NAME\" found" 2>&1
    echo "$actual" 2>&1
    break
  else
    echo "Waiting for resource \"$RESOURCE/$NAME\" ..." 2>&1
    echo "$actual" 2>&1
  fi
  sleep 10s
  retries=$((retries - 1))
done