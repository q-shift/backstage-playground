#!/usr/bin/env bash

#
# Script for templating the jinja2 app-config.local.yaml file.
#

set -o errexit

JINJA2_TEMPLATE_VARIABLES=""

echo ""

set +e
while [ $# -gt 0 ]; do
    #echo "$1"
    if [[ $1 == "-"* ]]; then
        param="${1/-/}";
        shift;
        value="${1}";
        echo "param: ${param}, value: ${value}"
        shift;
        JINJA2_TEMPLATE_VARIABLES+=" -D${param}=${value}"
    fi
done
set -e

echo " "

echo "Templating app-config with the following parameters: "
echo "  ${JINJA2_TEMPLATE_VARIABLES}"

echo "Starting the template process..."

#echo "jinja2 ${JINJA2_TEMPLATE_VARIABLES} ./manifest/app-config.local.yaml.j2 > app-config.local.yaml"
#jinja2 ${JINJA2_TEMPLATE_VARIABLES} ./manifest/app-config.local.yaml.j2
jinja2 ${JINJA2_TEMPLATE_VARIABLES} ./manifest/app-config.local.yaml.j2 --strict > app-config.local.yaml

echo "Template process finished!"