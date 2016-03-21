#!/bin/sh

set -e

# JTB dep installer for travis
# Id: jtb/0.0.2-test install-dependencies.sh

test -n "$JJB_HOME" || {
  # default checkout dir at travis
  JJB_HOME=$HOME/build/jjb
}

test -n "$JJB_HOME" || {
    err "No JJB_HOME var $JJB_HOME" 1
}

test -n "$JTB_SH_BIN" || JTB_SH_BIN=$JTB_HOME/bin
test -n "$JTB_SH_LIB" || JTB_SH_LIB=$JTB_HOME/lib
# share dist with JJB YAML files
test -n "$JTB_JJB_LIB" || JTB_JJB_LIB=$JTB_HOME/dist
# share tools, script, tpl?
test -n "$JTB_SHARE" || JTB_SHARE=$JTB_HOME

test -n "$verbosity" || verbosity=4


. $JTB_SH_LIB/util.sh


install_jjb()
{
  test -d "$JJB_HOME" && {

    log "JJB_HOME exists: $JJB_HOME"

  } || {

    mkdir -vp $(dirname $JJB_HOME)

    log "Cloning JJB.."
    git clone https://git.openstack.org/openstack-infra/jenkins-job-builder $JJB_HOME \
      || err "Error cloning to $JJB_HOME" 1

    log "Installing JJB.."
    pushd $JJB_HOME

    # Install into ~/..user-packages
    python setup.py install --user \
      && log "JJB install complete" \
      || err "Error during JJB installation" 1

    popd
  }

  jenkins-jobs --version && {
    log "JJB install OK"
  } || {
    err "JJB installation invalid" 1
  }
}

test -n "$1" && type $1 &> /dev/null && {
  cmd=$1
  shift 1
  $cmd $@
}

