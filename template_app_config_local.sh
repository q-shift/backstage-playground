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

# Check the system requirements
check_requirements() {
    if ! command -v jinja2 &> /dev/null
    then
        log_message 0 "ERROR: jinja2 not installed!"
        log_message 0 "  For more information check the project page at https://jinja.palletsprojects.com/"
        exit 1
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
    echo -e "--accept_defaults\t\tWhen defaults are proposed accept them without prompting for input."
    echo -e "--batch\t\t\t\tExecute in batch mode. Skips the parameter prompt."
    echo -e "--help\t\t\t\tShow this message"
    echo -e "--template_file <value>\t\tPath to use your custom backstage app-config template file."
    echo -e "--verbosity <value>\t\tVerbosity level for the script output."
    echo ""
    echo "Template variables will be provided using the - prefix, e.g.:"
    echo "  -BACKSTAGE_APP_BASE_URL localhost:3000"
    echo ""
    exit 1
}

prompt_variable() {
    log_message 9 "## prompt_variable script"
    declare name=$1
    declare prompt_text=$2
    declare is_secret=$3
    declare default_value=$4
    if [ "${is_secret}" -eq "1" ]; then
        read_switch='-sp'
    else
        read_switch='-p'
    fi
    if [ -n "$default_value" ]; then
        prompt_text+=" (default: ${default_value})"
    fi
    log_message 9 "## Prompt variable: <name: $name>; <default_value: $default_value>"
    if [ "${ACCEPT_DEFAULTS}" -eq "1" ] && [ -n "$default_value" ] ; then
        if [ "${is_secret}" -eq "1" ]; then
            JINJA2_TEMPLATE_SECRETS+=" -D${name}=${default_value}"
            log_message 9 "## JINJA2_TEMPLATE_SECRETS: <${JINJA2_TEMPLATE_SECRETS}>"
        else
            JINJA2_TEMPLATE_VARIABLES+=" -D${name}=${default_value}"
            log_message 9 "## JINJA2_TEMPLATE_VARIABLES: <${JINJA2_TEMPLATE_VARIABLES}>"
        fi
    else
        if [ -n "${!name}" ]; then
            log_message 5 "${name}: ${value}"
        else
            read ${read_switch} "${prompt_text}: " LOCAL_VARIABLE
            if [ "${is_secret}" -eq "1" ]; then
                # Change line, required for usability as the read was made without printing the characters.
                echo ""
            fi
            log_message 9 "## LOCAL_VARIABLE: <${LOCAL_VARIABLE}>"
            if [ -n "$LOCAL_VARIABLE" ]; then
                log_message 9 "## LOCAL_VARIABLE defined: <${LOCAL_VARIABLE}>"
                if [ "${is_secret}" -eq "1" ]; then
                    JINJA2_TEMPLATE_SECRETS+=" -D${name}=${LOCAL_VARIABLE}"
                    log_message 9 "## JINJA2_TEMPLATE_SECRETS: <${JINJA2_TEMPLATE_SECRETS}>"
                else
                    JINJA2_TEMPLATE_VARIABLES+=" -D${name}=${LOCAL_VARIABLE}"
                    log_message 9 "## JINJA2_TEMPLATE_VARIABLES: <${JINJA2_TEMPLATE_VARIABLES}>"
                fi
            else
                log_message 9 "## LOCAL_VARIABLE not defined, using default if exists: <${LOCAL_VARIABLE},${default_value}>"
                if [ -n "$default_value" ]; then
                    log_message 9 "## default is defined: <${default_value}>"
                    if [ "${is_secret}" -eq "1" ]; then
                        JINJA2_TEMPLATE_SECRETS+=" -D${name}=${default_value}"
                        log_message 9 "## JINJA2_TEMPLATE_SECRETS: <${JINJA2_TEMPLATE_SECRETS}>"
                    else
                        JINJA2_TEMPLATE_VARIABLES+=" -D${name}=${default_value}"
                        log_message 9 "## JINJA2_TEMPLATE_VARIABLES: <${JINJA2_TEMPLATE_VARIABLES}>"
                    fi
                fi
            fi
        fi
    fi
    log_message 9 ""
}

# Prompt the input variables
prompt_variables() {
    log_message 9 "## # prompt_variable script"
    log_message 0 ""

    if [ -n "$JINJA2_TEMPLATE_FILE" ]; then
        log_message 5 "JINJA2_TEMPLATE_FILE: ${JINJA2_TEMPLATE_FILE}"
    else
        prompt_variable 'JINJA2_TEMPLATE_FILE' 'Template file location' 0 './manifest/app-config.local.yaml.j2'
        # read -p 'Template file location (default: ./manifest/app-config.local.yaml.j2): ' JINJA2_TEMPLATE_FILE
        # if [ ! -n "$JINJA2_TEMPLATE_FILE" ]; then
        #     JINJA2_TEMPLATE_FILE='./manifest/app-config.local.yaml.j2'
        # fi
    fi

    if [ -n "$BACKSTAGE_BASE_URL" ]; then
        log_message 5 "BACKSTAGE_BASE_URL: ${BACKSTAGE_BASE_URL}"
    else
        prompt_variable 'BACKSTAGE_BASE_URL' 'Backstage URL' 0 'localhost'
    fi

    # if [ -n "$BACKSTAGE_APP_BASE_URL" ]; then
    #     log_message 5 "BACKSTAGE_APP_BASE_URL: ${BACKSTAGE_APP_BASE_URL}"
    # else
    #     prompt_variable 'BACKSTAGE_APP_BASE_URL' 'Backstage URL' 0 'localhost'
    # fi

    if [ -n "$BACKSTAGE_FRONTEND_BASE_PORT" ]; then
        log_message 5 "BACKSTAGE_FRONTEND_BASE_PORT: ${BACKSTAGE_FRONTEND_BASE_PORT}"
    else
        prompt_variable 'BACKSTAGE_FRONTEND_BASE_PORT' 'Backstage frontend application port' 0 '3000'
    fi

    # if [ -n "$BACKSTAGE_BACKEND_BASE_HOST" ]; then
    #     log_message 5 "BACKSTAGE_BACKEND_BASE_HOST: ${BACKSTAGE_BACKEND_BASE_HOST}"
    # else
    #     prompt_variable 'BACKSTAGE_BACKEND_BASE_HOST' 'Backstage Backend Base Host' 0 'localhost'
    # fi

    if [ -n "$BACKSTAGE_BACKEND_BASE_PORT" ]; then
        log_message 5 "BACKSTAGE_BACKEND_BASE_PORT: ${BACKSTAGE_BACKEND_BASE_PORT}"
    else
        prompt_variable 'BACKSTAGE_BACKEND_BASE_PORT' 'Backstage backend application port' 0 '7007'
    fi

    if [ -n "$BACKSTAGE_AUTH_SECRET" ]; then
        log_message 5 "BACKSTAGE_AUTH_SECRET: ********"
    else
        prompt_variable 'BACKSTAGE_AUTH_SECRET' 'Backstage Authentication Secret' 1 $(node -p 'require("crypto").randomBytes(24).toString("base64")')
    fi

    if [ -n "$TEMPLATE_URL" ]; then
        log_message 5 "TEMPLATE_URL: ${TEMPLATE_URL}"
    else
        prompt_variable 'TEMPLATE_URL' 'Catalog Template URL' 0 'https://github.com/ch007m/my-backstage-templates/blob/main/qshift/all.yaml'
    fi

    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        log_message 5 "GITHUB_PERSONAL_ACCESS_TOKEN: ********"
    else
        prompt_variable 'GITHUB_PERSONAL_ACCESS_TOKEN' 'The GitHub Personal Access Token to access your Org' 1
    fi

    if [ -n "$ARGOCD_SERVER" ]; then
        log_message 5 "ARGOCD_SERVER: ${ARGOCD_SERVER}"
    else
        prompt_variable 'ARGOCD_SERVER' 'ArgoCD Server' 0
    fi

    if [ -n "$ARGOCD_AUTH_TOKEN" ]; then
        log_message 5 "ARGOCD_AUTH_TOKEN: ********"
    else
        prompt_variable 'ARGOCD_AUTH_TOKEN' 'ArgoCD Authentication Token' 1
    fi

    if [ -n "$ARGOCD_ADMIN_PASSWORD" ]; then
        log_message 5 "ARGOCD_ADMIN_PASSWORD: ********"
    else
        prompt_variable 'ARGOCD_ADMIN_PASSWORD' 'ArgoCD Admin Password' 1
    fi

    if [ -n "$KUBERNETES_SERVICE" ]; then
        log_message 5 "KUBERNETES_SERVICE: ${KUBERNETES_SERVICE}"
    else
        prompt_variable 'KUBERNETES_SERVICE' 'Kubernetes Service' 0 'https://kubernetes.default.svc'
    fi

    if [ -n "$SERVICE_ACCOUNT_TOKEN" ]; then
        log_message 5 "SERVICE_ACCOUNT_TOKEN: ********"
    else
        prompt_variable 'SERVICE_ACCOUNT_TOKEN' 'Service Account Token' 1
    fi
}

#################################################################

BATCH_EXECUTION=0
ACCEPT_DEFAULTS=0
DEFAULT_JINJA2_TEMPLATE_FILE="./manifest/app-config.local.yaml.j2"
JINJA2_TEMPLATE_VARIABLES=""
JINJA2_TEMPLATE_SECRETS=""
LOGGING_VERBOSITY=1

check_requirements

set +e
while [ $# -gt 0 ]; do
    log_message 9 "## $1"
    if [[ $1 == "--"* ]]; then
        case $1 in
            --accept_defaults) ACCEPT_DEFAULTS=1; shift ;;
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
        log_message 9 "## param: ${param}, value: ${value}"
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
log_message 5 "  jinja2 ${JINJA2_TEMPLATE_VARIABLES} ${JINJA2_TEMPLATE_SECRETS} ${JINJA2_TEMPLATE_FILE} --strict > app-config.local.yaml"

log_message 1 ""
log_message_nonl 1 "Starting the template process..."

jinja2 ${JINJA2_TEMPLATE_VARIABLES} ${JINJA2_TEMPLATE_SECRETS} ${JINJA2_TEMPLATE_FILE} --strict > app-config.local.yaml

log_message 1 " OK!"
