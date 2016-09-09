#!/bin/sh

set -e

scriptname=jtb.sh
version=0.0.3 # jtb

test -n "$JTB_HOME" || export JTB_HOME=$(dirname $(dirname $0))
test -n "$JTB_SH_BIN" || export JTB_SH_BIN=$JTB_HOME/bin
test -n "$JTB_SH_LIB" || export JTB_SH_LIB=$JTB_HOME/lib
# share dist with JJB YAML files
test -n "$JTB_JJB_LIB" || export JTB_JJB_LIB=$JTB_HOME/dist
# share tools, script, tpl?
test -n "$JTB_SHARE" || export JTB_SHARE=$JTB_HOME

test -n "$verbosity" || verbosity=4

#PREFIX=$JTB_HOME
#PREFIX=/usr/
#PREFIX=/usr/local/
#PREFIX=$HOME/.local


test -n "$1" && {
  subcmd="$1"
  shift 1
} || {
  subcmd=usage
}

. $JTB_SH_LIB/util.sh
. $JTB_SH_LIB/jtb.sh
. $JTB_SH_LIB/user-scripts.sh

subcmd_func="$(var_id jtb__$subcmd)"

$subcmd_func "$@" && {
  exit 0
} || {
  error "Failed running sub-command ($subcmd_func)" $?
}

