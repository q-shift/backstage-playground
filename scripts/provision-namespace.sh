#!/bin/bash

execute_kubectl() {
  local command=$1
  if $DRY_RUN; then
    echo "kubectl --dry-run=client $command "
    kubectl --dry-run=client $command
  else
    echo "kubectl $command"
    kubectl $command
  fi
}

execute_oc() {
  local command=$1
  if $DRY_RUN; then
    echo "oc $command "
  else
    echo "oc $command"
    oc $command
  fi
}

# Display usage
function usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -n, --namespace     <namespace>                        The namespace on the QShift cluster (mandatory)"
  echo "  -q, --quay          <quay_username:quay_password>      The Quay username and password (mandatory)"
  echo "  -o, --quay-org      <quay_username:quay_password>      The Quay organization hosting the images (mandatory)"
  echo "  -d, --docker        <docker_username:docker_password>  The docker username and password (mandatory)"
  echo "  -k, --key-path      <public_key_path>                  The path of your public to ssh to the VM (mandatory)"
  echo "  -r, --dry-run                                          Run the kubectl command with dry-run=client"
  exit 1
}

while [[ $# -gt 0 ]]; do
  echo "Processing $1"
  case $1 in
    -n|--namespace)
      NAMESPACE=$2
      shift 2
      ;;
    -q|--quay)
      QUAY_CRED=$2
      shift 2
      ;;
    -o|--quay-org)
      QUAY_ORG=$2
      shift 2
      ;;
    -d|--docker)
      DOCKER_CRED=$2
      shift 2
      ;;
    -k|--key-path)
      PUBLIC_KEY_PASS=$2
      shift 2
      ;;
    -r|--dry-run)
      DRY_RUN=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [[ -z ${NAMESPACE+x} ]]; then
  echo "Error: NAMESPACE is not set" >&2
  usage
  exit 1
else
  echo "### Creating new project for: $NAMESPACE"
  execute_oc "new-project $NAMESPACE"
fi

if [[ -z ${QUAY_CRED+x} ]]; then
  echo "Error: QUAY_CRED is not set" >&2
  usage
  exit 1
else
  echo "QUAY_CRED provided :-)"
fi

if [[ -z ${QUAY_ORG+x} ]]; then
  echo "Error: QUAY_ORG is not set" >&2
  usage
  exit 1
else
  echo "QUAY_ORG: $QUAY_ORG"
fi

if [[ -z ${DOCKER_CRED+x} ]]; then
  echo "Error: DOCKER_CRED is not set" >&2
  usage
  exit 1
else
  echo "DOCKER_CRED provided :-)"
fi

QUAY_CREDS_BASE64=$(echo -n "$QUAY_CRED" | base64)
DOCKER_CRED_BASE64=$(echo -n "$DOCKER_CRED" | base64)

cat <<EOF > config.json
{
  "auths": {
    "quay.io/$QUAY_ORG": {
      "auth": "$QUAY_CREDS_BASE64"
    },
    "https://index.docker.io/v1/": {
      "auth": "$DOCKER_CRED_BASE64"
    }
  }
}
EOF

echo "### Creating container registry secret ..."
execute_kubectl "create secret generic dockerconfig-secret --from-file=config.json"

echo "### Creating the backstage service account"
execute_kubectl "create sa my-backstage"

echo "Give cluster-admin role to the backstage SA to access the kubernetes API resources"
cat <<EOF > rbac.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: backstage-$NAMESPACE-cluster-access
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: my-backstage
  namespace: $NAMESPACE
EOF

execute_kubectl "apply -f rbac.yml"

if [[ -z ${PUBLIC_KEY_PASS+x} ]]; then
  echo "Error: Public key path is not set" >&2
  usage
  exit 1
else
  echo "### Creating a secret hosting your SSH public key"
  execute_kubectl "create secret generic quarkus-dev-ssh-key --from-file=key=$PUBLIC_KEY_PASS"
  
  echo "### Creating the Fedora podman virtual machine"
  execute_kubectl "apply -f manifest/installation/virt/quarkus-dev-virtualmachine.yml"
fi

echo "### Apply the label: argocd.argoproj.io/managed-by=<argocd_namespace> on your namespace"
execute_kubectl "label namespace $NAMESPACE argocd.argoproj.io/managed-by=openshift-gitops"

echo "### Adding your namespace to the parameter: sourceNamespaces of the ArgoCD CR ..."
ARGOCD_NAME="argocd"
NAMESPACE_ARGOCD="openshift-gitops"

# Fetch the current ArgoCD resource
ARGOCD_JSON=$(kubectl get argocd $ARGOCD_NAME -n $NAMESPACE_ARGOCD -o json)

if echo "$ARGOCD_JSON" | jq -e --arg ns "$NAMESPACE" '.spec.sourceNamespaces | index($ns)' > /dev/null; then
  echo "Namespace '$NAMESPACE' already exists in sourceNamespaces."
else
  echo "Adding namespace '$NAMESPACE' to sourceNamespaces."
  PATCH=$(echo "$ARGOCD_JSON" | jq --arg ns "$NAMESPACE" '.spec.sourceNamespaces += [$ns] | {spec: {sourceNamespaces: .spec.sourceNamespaces}}')
  kubectl patch argocd $ARGOCD_NAME -n $NAMESPACE_ARGOCD --type merge --patch "$PATCH"
fi
