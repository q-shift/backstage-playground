# Backstage QShift Showcase

The backstage QShift application has been designed to showcase QShift (Quarkus on OpenShift) and integrate the following plugins:
- [Kubernetes plugin](https://backstage.io/docs/features/kubernetes/installation)
- [Quarkus plugin](https://github.com/q-shift/backstage-plugins)
- ArgoCD [front](https://github.com/RoadieHQ/roadie-backstage-plugins/tree/main/plugins/frontend/backstage-plugin-argo-cd) & [backend](https://github.com/RoadieHQ/roadie-backstage-plugins/tree/main/plugins/scaffolder-actions/scaffolder-backend-argocd)
- [Tekton Plugin](https://github.com/janus-idp/backstage-plugins/tree/main/plugins/tekton)

**Note**: It has been developed using backstage version: 1.21.0

## Prerequisites

- [Node.js](https://nodejs.org/en) (18 or 20)
- [nvm](https://github.com/nvm-sh/nvm), npm and [yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) installed
- Read this blog post: https://medium.com/@chrisschneider/build-a-developer-portal-with-backstage-on-openshift-d2a97aca91ee
- [GitHub client](https://cli.github.com/) (optional)
- [argocd client](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli) (optional)

## Instructions

### First steps

Before to run the backstage playground, it is needed to perform some first steps to be able to play the scenario without issues !

Verify first that you have access to an OCP4.x cluster where Argo CD, Kubevirt, Tekton have been installed (using their corresponding operator) and are configure properly

Next create within the namespace where the pipeline will be executed to build the image the following secret
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
kubectl create secret generic dockerconfig-secret -n <PIPELINE_NAMESPACE> --from-file=config.json
```
Create a GitHub Personal Access token (see backstage instruction [here](https://backstage.io/docs/getting-started/configuration/#setting-up-a-github-integration)) to been able to 
scaffold a Quarkus application within your GitHub organization

### Locally

To use this project, git clone it 

Create your `app-config.qshift.yaml` file using the [app-config.qshift-example.yaml](app-config.qshift-example.yaml) file included within this project.
Take care to provide the following password/tokens:
- GitHub Personal Access Token
- Argo CD Cluster password
- Argo CD Auth token
- etc

Next run the following command:

```sh
yarn install
yarn start --config ../../app-config.qshift.yaml
yarn start-backend --config ../../app-config.qshift.yaml
```

**Warning**: If you use node 20, then export the following env var `export NODE_OPTIONS=--no-node-snapshot` as documented [here](https://backstage.io/docs/getting-started/configuration/#create-a-new-component-using-a-software-template).

Next open backstage URL, select from the left menu `/create` and scaffold a new project using the template `Create a Quarkus application`

### On OCP

First, log on to the ocp cluster and verify if the following operators have been installed: 

- Red Hat OpenShift GitOps operator (>=1.11)
- Red Hat OpenShift Pipelines (>= 1.13.1)

Create the `app-config.qshift.yaml` file containing the appropriate password, tokens, urls, etc and create a ConfigMap packaging it.

**Remark**: The baseURL within the app-config file should be the same as the ingress host as defined within the Helm values: `idp-backstage.apps.qshift.snowdrop.dev`

Next, deploy it within the namespace where backstage will run.

```bash
NAMESPACE=backstage
kubectl create configmap my-app-config -n $NAMESPACE \
  --from-file=app-config.qshift.yaml=app-config.qshift.yaml \
  -o yaml --dry-run=client | kubectl apply -n $NAMESPACE -f -
```
Deploy backstage on the platform using this ArgoCD Application CR:
```bash
kubectl apply -f manifest/argocd.yaml
```

**NOTE**: This project builds (with the help iof a GitHub workflow) the backstage container image for openshift and pushes it on `quay.io/ch007m/backstage-qshift-ocp`

Verify if backstage is alive using the URL: `https://idp-backstage.apps.qshift.snowdrop.dev`

### Clean up

To delete the GitHub repository created like the ArgoCD resources on the QShift server, use the following commands
```bash
app=my-quarkus-app
gh repo delete github.com/ch007m/$app --yes

ARGOCD_SERVER=openshift-gitops-server-openshift-gitops.apps.qshift.snowdrop.dev
ARGOCD_PWD=<ARGOCD_PWD>
ARGOCD_USER=admin
argocd login --insecure $ARGOCD_SERVER --username $ARGOCD_USER --password $ARGOCD_PWD --grpc-web

argocd app delete $app-bootstrap --grpc-web -y
argocd app list --grpc-web
```


## Tools

### `app-config.yaml` template

The `template_app_config_local.sh` is a tool to help in the generation of 
 the `app-config.yaml` file. 

The goal of the bash script is to transform the provided parameters into 
 `jinja2` variables that will be replaced inside the script.

The script prompts variables to the user upon execution, 
 **unless they are defined using the inputs of the script**.

**NOTE**: The script is executed in _strict_ mode so all the 
 variables that are defined in the template and don't have a _default_ 
 value must be provided.

| Variable | Meaning |
| --- | --- |
| `--accept_defaults` | When defaults are proposed accept them without prompting for input. |
| `--batch` | Execute in batch mode. Skips the parameter prompt. |
| `--help` | Show the script help message. |
| `--template_file` | Path to use your custom backstage app-config template file. |
| `--verbosity` | Verbosity level for the script output. |

When called without the batch mode the input parameters will be requested to the user, if not already defined.


```bash
./template_app_config_local.sh
```

```
Template file location (default: ./manifest/app-config.local.yaml.j2): 
Backstage APP Base URL (default: localhost:3000): 
Backstage Backend Base Host (default: localhost): 
Backstage Backend Base Port (default: 7007): 
Catalog Template URL (default: https://github.com/ch007m/my-backstage-templates/blob/main/qshift/all.yaml): 
The GitHub Personal Access Token to access your Org: 
ArgoCD Server: 
ArgoCD Admin Password: 
Kubernetes Service (default: https://kubernetes.default.svc): 
Service Account Token: 
```

```bash
./template_app_config_local.sh --batch \
  -SERVICE_ACCOUNT_TOKEN I_WONT_TELL \
  -ARGOCD_ADMIN_PASSWORD password \
  -ARGOCD_SERVER https://openshift-gitops-server-openshift-gitops.apps.qshift.snowdrop.dev/ \
  -GITHUB_PERSONAL_ACCESS_TOKEN I_WONT_TELL_EITHER
```

Print the help.

```bash
$ ./template_app_config_local.sh --help

Script for templating the jinja2 app-config.yaml file.

NOTE: The script parameters must come before the template parameters.

Syntax:

template_app_config_local.sh <parameters> <template variables>

Script optional parameters:

--accept_defaults         When defaults are proposed accept them without prompting for input.
--batch				            Execute in batch mode. Skips the parameter prompt.
--help				            Show this message
--template_file <value>		Path to use your custom backstage app-config template file.
--verbosity <value>		    Verbosity level for the script output.

Template variables will be provided using the - prefix, e.g.:
  -BACKSTAGE_BASE_URL localhost
```
