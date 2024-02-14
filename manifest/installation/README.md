# Commands used to get the resources and/or to redeploy them on a new cluster

## Virt

https://github.com/q-shift/openshift-vm-playground?tab=readme-ov-file#instructions-to-create-a-vm-and-to-ssh-to-it

```bash
file=subscription-kubevirt-hyperconverged
k -n openshift-cnv get subscription/kubevirt-hyperconverged -o json > $file.json
cat $file.json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > $file-clean.json
yq -p json -o yaml $file-clean.json > $file.yml

k get hyperConverged/kubevirt-hyperconverged -n openshift-cnv -o json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > hyperConverged.json

yq -p json -o yaml hyperConverged.json > hyperConverged.yml
rm *.json
```

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

To be fixed: `message: DataVolume.storage spec is missing accessMode and no storageClass to`
! NFS storage is not created OOTB on ocp cluster running on resourcehub. So the storage class should be created as
documented: https://redhat-appstudio.github.io/infra-deployments/hack/quickcluster/README.html
```bash

./setup-nfs-quickcluster.sh upi-0.newqshift.lab.upshift.rdu2.redhat.com
```

Next you should patch it
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

```bash
file=subscription-gitops
k -n openshift-gitops-operator get subscription/openshift-gitops-operator -o json > $file.json
cat $file.json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > $file-clean.json
yq -p json -o yaml $file-clean.json > $file.yml
rm *.json
```
To subscribe to the operator and create the needed CR

```bash
kubectl create ns openshift-gitops-operator
kubectl apply -f subscription-gitops.yml
```
To customize argocd, it is needed to delete the existing `ArgoCD` CR and to deploy the following (TODO: to be patched):
Our modified CR include: `sourceNamespaces`, `extraConfig` and `tls.termination: reencrypt` and `resourceExclusions` (TODO: to document)
```bash
kubectl delete argoproject/default -n openshift-gitops
kubectl apply -f argocd.yml
```

Patch the AppProject CR to support Applications deployed in [different namespaces](https://github.com/q-shift/backstage-playground/issues/39#issuecomment-1938403564).
```bash
kubectl get AppProject/default -n openshift-gitops -o json | jq '.spec.sourceNamespaces += ["*"]' | kubectl apply -f -
```
## Tekton

```bash
file=subscription-pipelines
k -n openshift-operators get subscription/openshift-pipelines-operator-rh -o json > $file.json
cat $file.json | jq 'del(.metadata.resourceVersion,.metadata.uid,.metadata.selfLink,.metadata.creationTimestamp,.metadata.annotations,.metadata.generation,.metadata.ownerReferences,.status)' > $file-clean.json
yq -p json -o yaml $file-clean.json > $file.yml
rm *.json
```
To subscribe to the operator and create the needed CR

```bash
kubectl apply -f subscription-pipelines.yml
```

## Next

TODO

```bash
oc adm policy add-cluster-role-to-user admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/managed-by: openshift-gitops
    app.kubernetes.io/name: argocd-application-controller
    app.kubernetes.io/part-of: argocd
  name: openshift-gitops-openshift-gitops-argocd-application-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: openshift-gitops-openshift-gitops-argocd-application-controller
subjects:
- kind: ServiceAccount
  name: openshift-gitops-argocd-application-controller
  namespace: openshift-gitops
```

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