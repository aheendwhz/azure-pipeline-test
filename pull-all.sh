#!/usr/bin/env bash

set -e

_print() { echo -e "\e[36;1m${1}\e[0m"; }

for i in ./data/envs/*; do

  ENV=$(echo $i | cut -d'/' -f 4)

  _print "pulling ${ENV}..."
  rm -rf $i
  babelforce-ivr-sync get --env $ENV

done

