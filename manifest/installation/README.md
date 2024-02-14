# Installation

Commands to be used to deploy Qshift on a new OCP cluster (e.g. 4.14.7)

## Virt

https://github.com/q-shift/openshift-vm-playground?tab=readme-ov-file#instructions-to-create-a-vm-and-to-ssh-to-it

To subscribe to the operator and create the needed CR
**Note**: The version of the operator could be different according to the cluster version used but the platform will then bump the version from by example `startingCSV: kubevirt-hyperconverged-operator.v4.14.0` to `startingCSV: kubevirt-hyperconverged-operator.v4.14.3`

```bash
kubectl create ns openshift-cnv
kubectl apply -f subscription-kubevirt-hyperconverged.yml
kubectl apply -f hyperConverged.yml
```

To install our customized fedora image, create a DataVolume
```bash
kubectl -n openshift-virtualization-os-images apply -f quay-to-pvc-datavolume.yml
```

**Note**: The following problem `message: DataVolume.storage spec is missing accessMode and no storageClass` only exists if you create a cluster on `https://resourcehub.redhat.com/` as the NFS provisioner is not created OOTB on the ocp cluster. So the storage stuffs should be created as
documented here: https://redhat-appstudio.github.io/infra-deployments/hack/quickcluster/README.html
```bash

./setup-nfs-quickcluster.sh upi-0.newqshift.lab.upshift.rdu2.redhat.com
```

Next you should patch the `StorageProfile` to give Write access permission to the NFS storage
```bash
kubectl patch --type merge -p '{"spec": {"claimPropertySets": [{"accessModes": ["ReadWriteOnce"]}]}}' StorageProfile managed-nfs-storage
```

To create a VM in a namespace
```bash
oc project <MY_NAMESPACE>
kubectl create secret generic quarkus-dev-ssh-key --from-file=key=$HOME/.ssh/id_rsa.pub
kubectl delete vm/quarkus-dev
kubectl apply -f quarkus-dev-virtualmachine.yml
```

## GitOps

To subscribe to the operator and create the needed CR

```bash
kubectl create ns openshift-gitops-operator
kubectl apply -f subscription-gitops.yml
```
To customize argocd, it is needed to delete the existing `ArgoCD` CR and to deploy the following (TODO: to be patched):
Our modified CR includes different changes: `sourceNamespaces`, `extraConfig` and `tls.termination: reencrypt` and `resourceExclusions`
```bash
kubectl delete argoproject/default -n openshift-gitops
kubectl apply -f argocd.yml
```
**TODO**: Instead of deleting and recreating a new ArgoCD CR, we should patch it or install it using kustomize, helm chart. Example: https://github.com/redhat-cop/agnosticd/blob/development/ansible/roles_ocp_workloads/ocp4_workload_openshift_gitops/templates/openshift-gitops.yaml.j2

Patch the AppProject CR to support Applications deployed in [different namespaces](https://github.com/q-shift/backstage-playground/issues/39#issuecomment-1938403564).
```bash
kubectl get AppProject/default -n openshift-gitops -o json | jq '.spec.sourceNamespaces += ["*"]' | kubectl apply -f -
```

When we install a new application CR in a namespace which is not the default one, then the following error is returned
```yaml
serviceaccounts is forbidden: User "system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller"
          cannot create resource "serviceaccounts" in API group "" in the namespace
          "cmoullia"'
```
To fix it, execute this command
```bash
oc adm policy add-cluster-role-to-user admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
```

## Tekton

To subscribe to the operator and create the needed CR

```bash
kubectl apply -f subscription-pipelines.yml
```

## Next

!! Managed by helm chart

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: cmoullia_qshift-backstage
  name: backstage-cluster-access
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: my-backstage
  namespace: cmoullia
```

TODO: Create a new resource able to set such a role to the pipeline SA of the namespace <MY_NAMESPACE>-test

oc adm policy add-cluster-role-to-user kubevirts.kubevirt.io-v1-view system:serviceaccount:qshift-test:pipeline
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubevirts.kubevirt.io-v1-view
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubevirts.kubevirt.io-v1-view
subjects:
- kind: ServiceAccount
  name: pipeline
  namespace: qshift-test
```

## Collect resources

```bash
file=subscription-kubevirt-hyperconverged
k -n openshift-cnv get subscription/kubevirt-hyperconverged -o json > $file.json
cat $file.json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > $file-clean.json
yq -p json -o yaml $file-clean.json > $file.yml

k get hyperConverged/kubevirt-hyperconverged -n openshift-cnv -o json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > hyperConverged.json

yq -p json -o yaml hyperConverged.json > hyperConverged.yml
rm *.json

file=subscription-gitops
k -n openshift-gitops-operator get subscription/openshift-gitops-operator -o json > $file.json
cat $file.json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > $file-clean.json
yq -p json -o yaml $file-clean.json > $file.yml
rm *.json

file=subscription-pipelines
k -n openshift-operators get subscription/openshift-pipelines-operator-rh -o json > $file.json
cat $file.json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > $file-clean.json
yq -p json -o yaml $file-clean.json > $file.yml
rm *.json
```