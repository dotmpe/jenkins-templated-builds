#!/bin/sh

set -e

scriptname=jtb.sh
version=0.0.4-dev # jtb

test -n "$ENV" || ENV=$(dirname "$0")/env.sh
. $ENV

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

