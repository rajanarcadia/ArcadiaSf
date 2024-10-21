#!/bin/bash
#use this script to add any custom configuration, data or metadata
#This should not be called as part of circle ci so that tests run correctly
# without permission sets assigned.

# bring in config file variables
source config/dx-utils.cfg

if [ $# -lt 1 ]
then
    echo Usage: customize_scratch_org.sh alias
    exit
fi

echo "Customizing Scratch Org: $1"

# assign any required permission sets
for permset in $DEFAULT_PERMISSION_SETS
do
    echo "Assigning permission set [$permset] to default user"
    sfdx force:user:permset:assign -n $permset
done

# assign any required permission sets
for license in $DEFAULT_PERMISSION_SET_LICENSES
do
    echo "Assigning permission set license [$license] to default user"
    sfdx force:user:permsetlicense:assign -n $license
done

#run anonymous apex scripts 
sfdx force:apex:execute -f dx-utils/apex-scripts/get_username.cls -o $1

#generate a password for default user
#this is used by puppet 
sfdx force:user:password:generate

#Generate Org details into scratchorgdetails/<orgalias>
./dx-utils/scratch_org_info.sh $1

#create users
for username in $DEFAULT_USERS
do
    echo "Creating user [$username]"
    ./dx-utils/create_user.sh $1 $username
done

echo "Installing CanvasPackageDevelopment" 

sfdx force:package:install -p CanvasPackageDevelopment@1.0.0-1

echo "Deploying Settings" 

sfdx force:mdapi:deploy -d settings-md/ -w 5

echo "Running Apex Scripts for Scratch Org Setup"

echo "UserPermission_Assignment"

sfdx force:apex:execute -f dx-utils/apex-scripts/scratch_org_steps_1.cls -o $1

echo "UpdateCustomSettingsData"

sfdx force:apex:execute -f dx-utils/apex-scripts/scratch_org_steps_5.cls -o $1

echo "CreateTestAccountSupplierEFrecords"

sfdx force:apex:execute -f dx-utils/apex-scripts/scratch_org_steps_9.cls -o $1

