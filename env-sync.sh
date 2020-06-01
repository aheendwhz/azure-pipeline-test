#!/usr/bin/env bash

set -e

STAMP=$(date --iso-8601=seconds)

# jobs
DEPLOY_TO_PROD="enbw.dev-to-enbw.staging"
BACKUP="enbw.dev-backup"


# commit artifacts to version control
commit() { git add . && git commit -m $STAMP ; }


# clean and pull current IVR state for all envs
pull_all() {

  for i in ./data/envs/*; do

    rm -rf $i
    babelforce-ivr-sync get --env $(echo $i | cut -d'/' -f 4)

  done

  echo "all IVRs have been reset!"
}

pull_all


