#!/usr/bin/env bash

set -e

STAMP=$(date --iso-8601=seconds)

_print() { echo -e "\e[36;1m${1}"; }

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

  # backup process is to pull latest state
  # of IVRs and put into version control
  "backup")

    pull_all
    commit
    ;;

esac
