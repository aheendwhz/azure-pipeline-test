#!/usr/bin/env bash

set -e

STAMP=$(date +%s)

_print() { echo -e "\e[36;1m${1}\e[0m"; }

# commit artifacts to version control
commit() {

  _print "committing current IVR states..."
  git add . && git commit -m $STAMP

}


# clean and pull current IVR state for all envs
pull_all() {

  for i in ./data/envs/*; do

    local ENV=$(echo $i | cut -d'/' -f 4)

    _print "pulling ${ENV}..."
    rm -rf $i
    babelforce-ivr-sync get --env $ENV

  done

  _print "all IVR states have been pulled"
}


case $1 in

  # pull latest state of IVRs and version them
  "backup")

    pull_all && commit
    ;;

  "rollback")

    # pull current state & hard-reset 1 commit
    _print "rolling back to last IVR state versions..."
    git reset --hard HEAD~1

    # print diff for sync task, then apply
    babelforce-ivr-sync diff enbw.dev-revert
    babelforce-ivr-sync apply enbw.dev-revert --no-confirm

    commit && _print "rollback successful"
    ;;

  "deploy-prod")

    # pull states, print diff then apply changes across envs
    _print "starting production deployment..."
    pull_all

    babelforce-ivr-sync diff enbw.dev-to-enbw.staging
    babelforce-ivr-sync apply enbw.dev-to-enbw.staging --no-confirm

    commit && _print "deployment sucessful"
    ;;

esac
