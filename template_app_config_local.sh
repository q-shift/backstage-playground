#!/usr/bin/env bash

#
# Script for templating the jinja2 app-config.local.yaml file.

set -o errexit

log_message() {
    VERBOSITY_LEVEL=$1
    MESSAGE="${@:2}"
    if [ "${LOGGING_VERBOSITY}" -ge "${VERBOSITY_LEVEL}" ]; then
        echo -e "${MESSAGE}"
    fi
}

log_message_nonl() {
    VERBOSITY_LEVEL=$1
    MESSAGE="${@:2}"
    if [ "${LOGGING_VERBOSITY}" -ge "${VERBOSITY_LEVEL}" ]; then
        echo -ne "${MESSAGE}"
    fi
}


show_usage () {
    echo ""
    echo "Script for templating the jinja2 app-config.yaml file."
    echo ""
    echo "NOTE: The script parameters must come before the template parameters."
    echo ""
    echo "Syntax:"
    echo ""
    echo "template_app_config_local.sh <parameters> <template variables>"
    echo ""
    echo "Script optional parameters:"
    echo ""
    echo -e "--batch\t\t\t\tExecute in batch mode. Skips the parameter prompt."
    echo -e "--help\t\t\t\tShow this message"
    echo -e "--template_file <value>\t\tCustom location for the template file."
    echo -e "--verbosity <value>\t\tVerbosity level for the script output."
    echo ""
    echo "Template variables will be provided using the - prefix, e.g.:"
    echo "  -BACKSTAGE_APP_BASE_URL localhost:3000"
    echo ""
    exit 1
}

# Promot the input variables
prompt_variables() {
    echo " "

    if [ -n "$JINJA2_TEMPLATE_FILE" ]; then
        log_message 5 "JINJA2_TEMPLATE_FILE: ${JINJA2_TEMPLATE_FILE}"
    else
        read -p 'Template file location (default: ./manifest/app-config.local.yaml.j2): ' JINJA2_TEMPLATE_FILE
        if [ ! -n "$JINJA2_TEMPLATE_FILE" ]; then
            # JINJA2_TEMPLATE_VARIABLES+=" -DJINJA2_TEMPLATE_FILE='${JINJA2_TEMPLATE_FILE}'"
        # else
            JINJA2_TEMPLATE_FILE='./manifest/app-config.local.yaml.j2'
        fi
    fi

    if [ -n "$BACKSTAGE_APP_BASE_URL" ]; then
        log_message 5 "BACKSTAGE_APP_BASE_URL: ${BACKSTAGE_APP_BASE_URL}"
    else
        read -p 'Backstage APP Base URL (default: localhost:3000): ' BACKSTAGE_APP_BASE_URL
        if [ -n "$BACKSTAGE_APP_BASE_URL" ]; then
            JINJA2_TEMPLATE_VARIABLES+=" -DBACKSTAGE_APP_BASE_URL=${BACKSTAGE_APP_BASE_URL}"
        fi
    fi

    if [ -n "$BACKSTAGE_BACKEND_BASE_HOST" ]; then
        log_message 5 "BACKSTAGE_BACKEND_BASE_HOST: ${BACKSTAGE_BACKEND_BASE_HOST}"
    else
        read -p 'Backstage Backend Base Host (default: localhost): ' BACKSTAGE_BACKEND_BASE_HOST
        if [ -n "$BACKSTAGE_BACKEND_BASE_HOST" ]; then
            JINJA2_TEMPLATE_VARIABLES+=" -DBACKSTAGE_BACKEND_BASE_HOST=${BACKSTAGE_BACKEND_BASE_HOST}"
        fi
    fi

    if [ -n "$BACKSTAGE_BACKEND_BASE_PORT" ]; then
        log_message 5 "BACKSTAGE_BACKEND_BASE_PORT: ${BACKSTAGE_BACKEND_BASE_PORT}"
    else
        read -p 'Backstage Backend Base Port (default: 7007): ' BACKSTAGE_BACKEND_BASE_PORT
        if [ -n "$BACKSTAGE_BACKEND_BASE_PORT" ]; then
            JINJA2_TEMPLATE_VARIABLES+=" -DBACKSTAGE_BACKEND_BASE_PORT=${BACKSTAGE_BACKEND_BASE_PORT}"
        fi
    fi

    if [ -n "$BACKSTAGE_AUTH_SECRET" ]; then
        log_message 5 "BACKSTAGE_AUTH_SECRET: ********"
    else
        read -sp 'Backstage Authentication Secret: ' BACKSTAGE_AUTH_SECRET
        echo ""
        if [ -n "$BACKSTAGE_AUTH_SECRET" ]; then
            JINJA2_TEMPLATE_SECRETS+=" -DBACKSTAGE_AUTH_SECRET=${BACKSTAGE_AUTH_SECRET}"
        fi
    fi

    if [ -n "$TEMPLATE_URL" ]; then
        log_message 5 "TEMPLATE_URL: ${TEMPLATE_URL}"
    else
        read -p 'Catalog Template URL (default: https://github.com/ch007m/my-backstage-templates/blob/main/qshift/all.yaml): ' TEMPLATE_URL
        if [ -n "$TEMPLATE_URL" ]; then
            JINJA2_TEMPLATE_VARIABLES+=" -DTEMPLATE_URL=${TEMPLATE_URL}"
        fi
    fi

    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        log_message 5 "GITHUB_PERSONAL_ACCESS_TOKEN: ********"
    else
        read -sp 'GitHub Personal Access Token: ' GITHUB_PERSONAL_ACCESS_TOKEN
        echo ""
        if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
            JINJA2_TEMPLATE_SECRETS+=" -DGITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN}"
        fi
    fi

    if [ -n "$ARGOCD_SERVER" ]; then
        log_message 5 "ARGOCD_SERVER: ${ARGOCD_SERVER}"
    else
        read -p 'ArgoCD Server: ' ARGOCD_SERVER
        if [ -n "$ARGOCD_SERVER" ]; then
            JINJA2_TEMPLATE_VARIABLES+=" -DARGOCD_SERVER=${ARGOCD_SERVER}"
        fi
    fi

    if [ -n "$ARGOCD_AUTH_TOKEN" ]; then
        log_message 5 "ARGOCD_AUTH_TOKEN: ********"
    else
        read -sp 'ArgoCD Authentication Token: ' ARGOCD_AUTH_TOKEN
        echo ""
        if [ -n "$ARGOCD_AUTH_TOKEN" ]; then
            JINJA2_TEMPLATE_SECRETS+=" -DARGOCD_AUTH_TOKEN=${ARGOCD_AUTH_TOKEN}"
        fi
    fi

    if [ -n "$ARGOCD_ADMIN_PASSWORD" ]; then
        log_message 5 "ARGOCD_ADMIN_PASSWORD: ********"
    else
        read -sp 'ArgoCD Admin Password: ' ARGOCD_ADMIN_PASSWORD
        echo ""
        if [ -n "$ARGOCD_ADMIN_PASSWORD" ]; then
            JINJA2_TEMPLATE_SECRETS+=" -DARGOCD_ADMIN_PASSWORD=${ARGOCD_ADMIN_PASSWORD}"
        fi
    fi

    if [ -n "$KUBERNETES_SERVICE" ]; then
        log_message 5 "KUBERNETES_SERVICE: ${KUBERNETES_SERVICE}"
    else
        read -p 'Kubernetes Service (default: https://kubernetes.default.svc): ' KUBERNETES_SERVICE
        if [ -n "$KUBERNETES_SERVICE" ]; then
            JINJA2_TEMPLATE_VARIABLES+=" -DKUBERNETES_SERVICE=${KUBERNETES_SERVICE}"
        fi
    fi

    if [ -n "$SERVICE_ACCOUNT_TOKEN" ]; then
        log_message 5 "SERVICE_ACCOUNT_TOKEN: ********"
    else
        read -sp 'Service Account Token: ' SERVICE_ACCOUNT_TOKEN
        echo ""
        if [ -n "$SERVICE_ACCOUNT_TOKEN" ]; then
            JINJA2_TEMPLATE_SECRETS+=" -DSERVICE_ACCOUNT_TOKEN=${SERVICE_ACCOUNT_TOKEN}"
        fi
    fi
}

#################################################################

BATCH_EXECUTION=0
DEFAULT_JINJA2_TEMPLATE_FILE="./manifest/app-config.local.yaml.j2"
JINJA2_TEMPLATE_VARIABLES=""
JINJA2_TEMPLATE_SECRETS=""
LOGGING_VERBOSITY=1

set +e
while [ $# -gt 0 ]; do
    log_message 9 "$1"
    if [[ $1 == "--"* ]]; then
        case $1 in
            --help) show_usage; break 2 ;;
            --batch) BATCH_EXECUTION=1; shift ;;
            --template_file) JINJA2_TEMPLATE_FILE="${2}"; shift; shift ;; 
            --verbosity) LOGGING_VERBOSITY="${2}"; shift; shift ;; 
            *) show_usage "Invalid switch $1" ; break 2 ;;
        esac
    elif [[ $1 == "-"* ]]; then
        param="${1/-/}";
        shift;
        value="${1}";
        shift;
        log_message 9 "param: ${param}, value: ${value}"
        case "$param" in 
            *SECRET*) JINJA2_TEMPLATE_SECRETS+=" -D${param}=${value}" ;;
            *TOKEN*) JINJA2_TEMPLATE_SECRETS+=" -D${param}=${value}" ;;
            *PASS*) JINJA2_TEMPLATE_SECRETS+=" -D${param}=${value}" ;;
            *) JINJA2_TEMPLATE_VARIABLES+=" -D${param}=${value}" ;;
        esac
        if [ ! "${BATCH_EXECUTION}" -eq "1" ]; then
        #     JINJA2_TEMPLATE_VARIABLES+=" -D${param}=${value}"
        # else
            declare $param=$value
        fi
    fi
done
set -e

if [ ! "${BATCH_EXECUTION}" -eq "1" ]; then
    prompt_variables
fi

if [ ! -n "$JINJA2_TEMPLATE_FILE" ]; then
    JINJA2_TEMPLATE_FILE="${DEFAULT_JINJA2_TEMPLATE_FILE}"
fi

log_message 2 ""
log_message 2 ""
log_message 2 "Templating app-config with the following parameters: "
log_message 2 "  ${JINJA2_TEMPLATE_VARIABLES}"

log_message 5 ""
log_message 5 "Command being called to generate the template:"
log_message 5 "  jinja2 ${JINJA2_TEMPLATE_VARIABLES} JINJA2_TEMPLATE_SECRETS ${JINJA2_TEMPLATE_FILE} --strict > app-config.local.yaml"

log_message 1 ""
log_message_nonl 1 "Starting the template process..."

jinja2 ${JINJA2_TEMPLATE_VARIABLES} ${JINJA2_TEMPLATE_SECRETS} ${JINJA2_TEMPLATE_FILE} --strict > app-config.local.yaml

log_message 1 " OK!"
