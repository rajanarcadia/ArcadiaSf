#!/bin/bash
#use this script to get scratch org details.  The deatils will be stored in scratchorgdetails/<orgalias>

#!/bin/bash

if [ $# -lt 1 ]
then
    echo Usage: scratch_org_info.sh alias user
    exit
fi
ORGALIAS=$1
OUTPUTDIR=scratchorgdetails/$1

if [ ! -d "$OUTPUTDIR" ]; then
  echo "Generating folder $OUTPUTDIR"
  # Control will enter here if $DIRECTORY doesn't exist.
  mkdir -p $OUTPUTDIR
fi

if [ $# -eq 1 ]
then
  echo "Generating file scratch_org_info.json..."
  sfdx force:org:display --verbose --json -o $ORGALIAS > $OUTPUTDIR/scratch_org_info.json
  sfdx force:org:display --verbose -o $ORGALIAS
  echo "Done."

  echo "Generating file scratch_user_info.json..."
  sfdx force:user:display --json -o $ORGALIAS > $OUTPUTDIR/scratch_user_info.json
  sfdx force:user:display -o $ORGALIAS
  echo "Done."

  echo "Generating file scratch_auth_info.json..."
  sfdx force:org:open --json -r -o $ORGALIAS  > $OUTPUTDIR/scratch_auth_info.json
  echo "Done."

else
  echo "Generating file scratch_user_info_$2.json..."
  sfdx force:user:display --json -o $2 > $OUTPUTDIR/scratch_user_info_$2.json
  echo "Done."
fi