#!/bin/sh

set -e

# JTB dep installer for travis

test -n "$JJB_HOME" || {
  # default checkout dir at travis
  JJB_HOME=$HOME/build/jjb
}

test -n "$JTB_HOME" || {
  JTB_HOME=.
}

test -n "$JTB_SH_BIN" || JTB_SH_BIN=$JTB_HOME/bin
test -n "$JTB_SH_LIB" || JTB_SH_LIB=$JTB_HOME/lib
# share dist with JJB YAML files
test -n "$JTB_JJB_LIB" || JTB_JJB_LIB=$JTB_HOME/dist
# share tools, script, tpl?
test -n "$JTB_SHARE" || JTB_SHARE=$JTB_HOME

test -n "$verbosity" || verbosity=4

test -n "$PREFIX" || {
PREFIX=/usr/local
}

test -n "$SRC_PREFIX" || {
SRC_PREFIX=$HOME/build
}

test -n "$JJB_HOME" || {
JJB_HOME=$SRC_PREFIX/jjb
}

test -n "$JTB_HOME" || {
JTB_HOME=$SRC_PREFIX/jtb
}

scriptname=$(basename $0)
. $JTB_SH_LIB/util.sh


install_jjb()
{
  test -d "$JJB_HOME" && {

    log "JJB_HOME exists: $JJB_HOME"

  } || {

    mkdir -vp $(dirname $JJB_HOME)

    test -n "$JJB_REPO" \
      || JJB_REPO=https://git.openstack.org/openstack-infra/jenkins-job-builder
    test -n "$JJB_BRANCH" || JJB_BRANCH=master

    log "Cloning JJB.."
    git clone $JJB_REPO $JJB_HOME \
      || err "Error cloning to $JJB_HOME" 1

    log "Installing JJB.."
    local pwd=$(pwd)
    cd $JJB_HOME
    git checkout $JJB_BRANCH

    # Install requirements
    pip install -r requirements.txt

    # Install into ~/..user-packages
    python setup.py install --user \
      && log "JJB install complete" \
      || err "Error during JJB installation" 1

    cd $pwd
  }

  jenkins-jobs --version && {
    log "JJB install OK"
  } || {
    err "JJB installation invalid" 1
  }
}

install_bats()
{
  echo "Installing bats"
  local pwd=$(pwd)
  test -n "$BATS_BRANCH" || BATS_BRANCH=master
  mkdir -vp $SRC_PREFIX
  cd $SRC_PREFIX
  test -n "$BATS_REPO" || BATS_REPO=https://github.com/sstephenson/bats.git
  test -n "$BATS_BRANCH" || BATS_BRANCH=master
  git clone $BATS_REPO bats
  cd bats
  git checkout $BATS_BRANCH
  ${sudo} ./install.sh $HOME/.local
  cd $pwd

  bats --version && {
    log "BATS install OK"
  } || {
    err "BATS installation invalid" 1
  }
}

test -n "$1" && {
  type $1 &> /dev/null && {
    cmd=$1
    shift 1
    $cmd $@
  }
} || {

  test -x "$(which jenkins-jobs)" || {
    install_jjb
  }

  # Check for BATS shell test runner or install
  test -x "$(which bats)" || {
    install_bats
  }

}

# Id: jtb/0.0.4-dev install-dependencies.sh
