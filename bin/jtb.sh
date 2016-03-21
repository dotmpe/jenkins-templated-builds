#!/bin/sh

set -e

scriptname=jtb.sh
version=0.0.2-master # jtb

test -n "$JTB_HOME" || JTB_HOME=.
test -n "$JTB_SH_BIN" || JTB_SH_BIN=$JTB_HOME/bin
test -n "$JTB_SH_LIB" || JTB_SH_LIB=$JTB_HOME/lib
# share dist with JJB YAML files
test -n "$JTB_JJB_LIB" || JTB_JJB_LIB=$JTB_HOME/dist
# share tools, script, tpl?
test -n "$JTB_SHARE" || JTB_SHARE=$JTB_HOME

test -n "$verbosity" || verbosity=4

#PREFIX=$JTB_HOME
#PREFIX=/usr/
#PREFIX=/usr/local/
#PREFIX=$HOME/.local


subcmd="$1"

shift 1

. $JTB_SH_LIB/util.sh
. $JTB_SH_LIB/jtb.sh
. $JTB_SH_LIB/user-scripts.sh

subcmd_func="$(var_id jtb__$subcmd)"

$subcmd_func "$@" && {
  exit 0
} || {
  error "running sub-command ($subcmd_func)" $?
}

