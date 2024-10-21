#!/bin/bash
#create a package version. Usage: create_package_version.sh PACKAGENAME POSTINSTALLURL TAG

# bring in config file variables
source config/dx-utils.cfg

if [ $# -lt 1 ]
then
    echo 'Usage: install_package_version.sh <scratch-alias> <package-version-id>'
fi

ALIAS=$1
PACKAGEID=$2

if [ -z "$PACKAGEID" ]
then
    echo 'Getting latest package version'
    PACKAGEID=$(sfdx force:package:version:list -p '' -o CreatedDate --concise | tail -1 | awk '{print $3}')
fi

echo "Install ${PACKAGEID} on scratch org ${ALIAS}"
sfdx force:package:install --package "${PACKAGEID}" -w 5 -u "${ALIAS}" --noprompt
