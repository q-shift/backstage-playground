
* [Backstage QShift Showcase](#backstage-qshift-showcase)
  * [Prerequisites](#prerequisites)
  * [Instructions](#instructions)
    * [First steps](#first-steps)
    * [Run backstage locally](#run-backstage-locally)
    * [Install me](#install-me)
      * [Kubevirt](#kubevirt)
      * [GitOps](#gitops)
      * [Tekton](#tekton)
    * [On OCP](#on-ocp)
    * [Clean up](#clean-up)


# Backstage QShift Showcase

The backstage QShift application has been designed to showcase QShift (Quarkus on OpenShift). It integrates the following plugins and backend systems:

| Backstage plugin                                                                                                                                                                                                                                          | Backend system                  | 
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
| [Core](https://backstage.io/plugins/)                                                                                                                                                                                                                     | GitHub                          |
| [Kubernetes](https://backstage.io/docs/features/kubernetes/)                                                                                                                                                                                              | Openshift                       |
| [Quarkus](https://github.com/q-shift/backstage-plugins)                                                                                                                                                                                                   | code.quarkus.io                 |
| [Quarkus Console](https://github.com/q-shift/backstage-plugins?tab=readme-ov-file#quarkus-console)                                                                                                                                                        | Openshift                       |
| ArgoCD [front](https://github.com/RoadieHQ/roadie-backstage-plugins/tree/main/plugins/frontend/backstage-plugin-argo-cd) & [backend](https://github.com/RoadieHQ/roadie-backstage-plugins/tree/main/plugins/scaffolder-actions/scaffolder-backend-argocd) | Red Hat Openshift GitOps 1.11.1 |
| [Tekton](https://github.com/janus-idp/backstage-plugins/tree/main/plugins/tekton)                                                                                                                                                                         | Red Hat Openshift 1.13.1        |
| [Topology](https://github.com/janus-idp/backstage-plugins/tree/main/plugins/topology)                                                                                                                                                                     | Red Hat Openshift Virt 4.14.7   |


**Note**: The backstage application is based on the backstage's version: 1.21.0

## Prerequisites

- [Node.js](https://nodejs.org/en) (18 or 20)
- [nvm](https://github.com/nvm-sh/nvm), npm and [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) installed
- Read this blog post: https://medium.com/@chrisschneider/build-a-developer-portal-with-backstage-on-openshift-d2a97aca91ee
- [GitHub client](https://cli.github.com/) (optional)
- [argocd client](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli) (optional)

## Instructions

### First steps

Before to run the backstage playground, it is needed to perform some first steps to be able to play the scenario without issues !

First, log on to the ocp cluster and verify if the following operators have been installed:

- Red Hat OpenShift [GitOps](https://docs.openshift.com/gitops/1.11/understanding_openshift_gitops/about-redhat-openshift-gitops.html) (>=1.11)
- Red Hat OpenShift [Pipelines](https://docs.openshift.com/pipelines/1.13/about/understanding-openshift-pipelines.html) (>= 1.13.1)
- Red Hat OpenShift [Virtualization](https://docs.openshift.com/container-platform/4.14/virt/about_virt/about-virt.html) (>= 4.14.3))

**Important**: Alternatively, you can follow the instructions of the section [Install me](#install-me) to install QShift on a new ocp cluster !

Create an OpenShift project where you will demo: `oc new-project <MY_NAMESPACE>`

Next create the following registry config.json file using your Quay and Docker credentials.
```bash
QUAY_CREDS=$(echo -n "<QUAY_USER>:<QUAY_TOKEN>" | base64)
DOCKER_CREDS=$(echo -n "<DOCKER_USER>:<DOCKER_PWD>" | base64)
QUAY_ORG=<QUAY_ORG>

cat <<EOF > config.json
{
  "auths": {
    "quay.io/${QUAY_ORG}": {
      "auth": "$QUAY_CREDS"
    },
    "https://index.docker.io/v1/": {
      "auth": "$DOCKER_CREDS"
    }
  }
}
EOF
```
and deploy it within the namespace `<MY_NAMESPACE>`

```bash
kubectl create secret generic dockerconfig-secret -n <MY_NAMESPACE> --from-file=config.json
```

Next git clone this project locally

### Run backstage locally

Create your `app-config.qshift.yaml` file using the [app-config.qshift.tmpl](manifest%2Ftemplates%2Fapp-config.qshift.tmpl) file included within this project.
Take care to provide the following password/tokens:

| Type                         |                                                                                   How to get it                                                                                    | 
|------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| GitHub Personal Access Token |                                   See [backstage doc](https://backstage.io/docs/getting-started/configuration/#setting-up-a-github-integration)                                    |
| Argo CD Cluster password     |                                `kubectl -n openshift-gitops get secret/openshift-gitops-cluster -ojson \| jq '.data."admin.password" \| @base64d'`                                 | 
| Argo CD Auth token           | `curl -sk -X POST -H "Content-Type: application/json" -d '{"username": "'${ARGOCD_USER}'","password": "'${ARGOCD_PWD}'"}' "https://$ARGOCD_SERVER/api/v1/session" \| jq -r .token` |
| Backstage's kubernetes Token |                                     `kubectl -n backstage get secret my-backstage-token-xxx -o go-template='{{.data.token \| base64decode}}'`                                      |

**Warning**: If you use node 20, then export the following env var `export NODE_OPTIONS=--no-node-snapshot` as documented [here](https://backstage.io/docs/getting-started/configuration/#create-a-new-component-using-a-software-template).

Next run the following commands:

```sh
yarn install
yarn start --config ../../app-config.qshift.yaml
yarn start-backend --config ../../app-config.qshift.yaml
```

You can now open the backstage URL `http://localhodt:3000`, select from the left menu `/create` and scaffold a new project using the template `Create a Quarkus application`

### Install me

The following section details the different commands to be used to deploy QShift on a new OCP cluster (e.g. 4.14.10)

#### Kubevirt

https://github.com/q-shift/openshift-vm-playground?tab=readme-ov-file#instructions-to-create-a-vm-and-to-ssh-to-it

To subscribe to the operator and create the needed CR
**Note**: The version of the operator could be different according to the cluster version used but the platform will then bump the version from by example `startingCSV: kubevirt-hyperconverged-operator.v4.14.0` to `startingCSV: kubevirt-hyperconverged-operator.v4.14.3`

```bash
cd manifest/installation/virt
kubectl create ns openshift-cnv
kubectl apply -f subscription-kubevirt-hyperconverged.yml
kubectl apply -f hyperConverged.yml
```

To install the customized fedora image packaging podman and socat, create now a `DataVolume` CR and wait till the image will be imported
```bash
kubectl -n openshift-virtualization-os-images apply -f quay-to-pvc-datavolume.yml
```

To create a VM in the namespace where you plan to demo
```bash
oc project <MY_NAMESPACE>
kubectl create secret generic quarkus-dev-ssh-key --from-file=key=$HOME/.ssh/id_rsa.pub
kubectl apply -f quarkus-dev-virtualmachine.yml
```
Verify if the VMI is well running
```bash
kubectl get vm -n <MY_NAMESPACE>
NAMESPACE   NAME          AGE   STATUS    READY
cmoullia    quarkus-dev   32s   Running   True
```

#### GitOps

To subscribe to the operator and create the needed CR

```bash
cd manifest/installation/gitops
kubectl create ns openshift-gitops-operator
kubectl apply -f subscription-gitops.yml
```

To use argocd with QShift, it is needed to delete the existing `ArgoCD` CR and to deploy our `Argo` CR.

**Note**: Our CR includes different changes needed to work with QShift: `sourceNamespaces`, `extraConfig` and `tls.termination: reencrypt` and `resourceExclusions` (TO BE DOCUMENTED)

```bash
kubectl delete argocd/openshift-gitops -n openshift-gitops
```
Substitute within the `ArgoCD` CR the <NAMESPACE> with your
```bash
cat argocd.tmpl | NAMESPACE=<MY_NAMESPACE> envsubst > argocd.yml
kubectl apply -f argocd.yml
```
**TODO**: Instead of deleting and recreating a new ArgoCD CR, we should patch it or install it using kustomize, helm chart. Example: https://github.com/redhat-cop/agnosticd/blob/development/ansible/roles_ocp_workloads/ocp4_workload_openshift_gitops/templates/openshift-gitops.yaml.j2

Patch the `AppProject` CR to support Applications deployed in [different namespaces](https://github.com/q-shift/backstage-playground/issues/39#issuecomment-1938403564).
```bash
kubectl get AppProject/default -n openshift-gitops -o json | jq '.spec.sourceNamespaces += ["*"]' | kubectl apply -f -
```

Finally, create a new ClusterRoleBinding to give the `Admin` role to the ServiceAccount `openshift-gitops-argocd-application-controller`. That will allow it to manage ArgoCD Application CR deployed in any namespace of the cluster

```bash
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-controller-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: ServiceAccount
  name: openshift-gitops-argocd-application-controller
  namespace: openshift-gitops
EOF
```

#### Tekton

To subscribe to the operator and create the needed CR

```bash
cd manifest/installation/tekton
kubectl apply -f subscription-pipelines.yml
```

### On OCP

The backstage application that you will deploy within your namespace is build with the help of a GitHub workflow and pushed here: `quay.io/ch007m/backstage-qshift-ocp`

Instead of using a local `app-config.yaml` file as we did within the previous section, we will configure for ocp the sensitive information using an env file able to override the app-config.yaml mounted as a volume from a ConfigMap.

**Trick**: The [backstage_env_secret.tmpl](manifest/templates/backstage_env_secret.tmpl) file contains what you need to get or set the sensitive information :-)

**Remark**: As the env variables should be substituted within the backstage [configuration](https://backstage.io/docs/conf/writing) file, please review the [configmap.app-config.yaml](manifest%2Fhelm%2Ftemplates%2Fconfigmap.app-config.yaml) file first to understand the purpose of the different parameters !

Create now the env secret's file from the template and set the sensitive information:
```bash
cp manifest/templates/backstage_env_secret.tmpl backstage_env_secret.env
```

Create a kubernetes generic secret using the env file: 
```bash
kubectl create secret generic my-backstage-secrets -n <MY_NAMESPACE> --from-env-file=backstage_env_secret.env
```

Deploy the q-shift backstage application:
```bash
cat manifest/templates/argocd.tmpl | NAMESPACE=<MY_NAMESPACE> DOMAIN=<OCP_CLUSTER_DOMAIN> envsubst > argocd.yaml
kubectl apply -f argocd.yaml
```
**Note**: The <OCP_CLUSTER_DOMAIN> corresponds to the Openshift domain (example: apps.newqshift.lab.upshift.rdu2.redhat.com, apps.qshift.snowdrop.dev)

As the Secret's token needed by the backstage kubernetes plugin will be generated post backstage deployment, then you will have to grab the token to update
your secret and next rollout the backstage Deployment resource.

Verify if backstage is alive using the URL: `https://backstage-<MY_NAMESPACE>.apps.qshift.snowdrop.dev` and start to play with the template `Create Quarkus Application`

**Warning**: To let argocd to deploy resources in your namespace, it is needed to patch the resource `kind: ArgoCD` to add your namespace using the field: `.spec.sourceNamespaces`. When patched, the argocd operator will rollout automatically the argocd server.
```bash
kubectl get argocd/openshift-gitops -n openshift-gitops -o json \
  | jq '.spec.sourceNamespaces += ["<MY_NAMESPACE>"]' | kubectl apply -f -
```

### Clean up

To delete the GitHub repository created like the ArgoCD resources on the QShift server when you scaffold a project using the `Create a Quarkus Application` [template](https://github.com/q-shift/qshift-templates/blob/main/qshift/templates/quarkus-application/template.yaml), use the following commands
```bash
app=my-quarkus-app
gh repo delete github.com/<GIT_ORG>/$app --yes

ARGOCD_SERVER=openshift-gitops-server-openshift-gitops.apps.qshift.snowdrop.dev
ARGOCD_PWD=<ARGOCD_PWD>
ARGOCD_USER=admin
argocd login --insecure $ARGOCD_SERVER --username $ARGOCD_USER --password $ARGOCD_PWD --grpc-web

argocd app delete <MY_NAMESPACE>/$app-bootstrap --grpc-web -y
argocd app list --grpc-web -N <MY_NAMESPACE>
```