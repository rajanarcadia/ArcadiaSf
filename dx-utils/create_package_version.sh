#!/bin/bash
#create a package version. Usage: create_package_version.sh PACKAGENAME POSTINSTALLURL TAG

source config/dx-utils.cfg

if [ $# -lt 1 ]
then
    PACKAGENAME=$DEFAULT_PACKAGE_NAME
    TAG=`git log -n 1 origin/staging --pretty=format:"%H"`
    POSTINSTALLURL=$DEFAULT_POST_INSTALL_CLASS
else
    PACKAGENAME=$1
    POSTINSTALLURL=$2
    TAG=$3
fi

if [ -z "$POSTINTALLURL" ]
then
    sfdx force:package:version:create --package "$PACKAGENAME" --wait 30 -x -c --tag "$TAG" -f config/project-scratch-def.json
else
    sfdx force:package:version:create --package "$PACKAGENAME" --wait 30 --postinstallurl "$POSTINSTALLURL" -x -c --tag "$TAG" -f config/project-scratch-def.json
fi