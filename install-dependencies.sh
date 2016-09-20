#!/bin/sh

set -e


# JTB dep installer for travis


test -z "$Build_Debug" || set -x

test -z "$Build_Deps_Default_Paths" || {
  test -n "$SRC_PREFIX" || SRC_PREFIX=$HOME/build
  test -n "$PREFIX" || PREFIX=$HOME/.local
# XXX: test -n "$PREFIX" || PREFIX=/usr/local
}

test -n "$sudo" || sudo=
test -z "$sudo" || pref="sudo $pref"
test -z "$dry_run" || pref="echo $pref"
test -n "$verbosity" || verbosity=4

test -n "$SRC_PREFIX" || {
  echo "Not sure where checkout"
  exit 1
}

test -n "$PREFIX" || {
  echo "Not sure where to install"
  exit 1
}

test -d $SRC_PREFIX || ${sudo} mkdir -vp $SRC_PREFIX
test -d $PREFIX || ${sudo} mkdir -vp $PREFIX


# default checkout dir at travis
test -n "$JJB_HOME" || JJB_HOME=$HOME/build/jjb

test -n "$JTB_HOME" || JTB_HOME=.

test -n "$JTB_SH_BIN" || JTB_SH_BIN=$JTB_HOME/bin
test -n "$JTB_SH_LIB" || JTB_SH_LIB=$JTB_HOME/lib
# share dist with JJB YAML files
test -n "$JTB_JJB_LIB" || JTB_JJB_LIB=$JTB_HOME/dist
# share tools, script, tpl?
test -n "$JTB_SHARE" || JTB_SHARE=$JTB_HOME

test -n "$JJB_HOME" || JJB_HOME=$SRC_PREFIX/jjb
test -n "$JTB_HOME" || JTB_HOME=$SRC_PREFIX/jtb


scriptname=$(basename $0)
. $JTB_SH_LIB/util.sh



install_bats()
{
  echo "Installing bats"
  local pwd=$(pwd)
  test -n "$BATS_BRANCH" || BATS_BRANCH=master
  mkdir -vp $SRC_PREFIX
  cd $SRC_PREFIX
  test -n "$BATS_REPO" || BATS_REPO=https://github.com/sstephenson/bats.git
  test -n "$BATS_BRANCH" || BATS_BRANCH=master
  test -d bats || {
    git clone $BATS_REPO bats || return $?
  }
  cd bats
  git checkout $BATS_BRANCH
  ${pref} ./install.sh $PREFIX
  cd $pwd

  bats --version && {
    log "BATS install OK"
  } || {
    err "BATS installation invalid" 1
  }
}

install_git_versioning()
{
  git clone https://github.com/dotmpe/git-versioning.git $SRC_PREFIX/git-versioning
  ( cd $SRC_PREFIX/git-versioning && ./configure.sh $PREFIX && ENV=production ./install.sh )
}

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
    git checkout $JJB_BRANCH || return $?

    # Install requirements
    pip install -r requirements.txt || return $?

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


main_entry()
{
  test -n "$1" || set -- '-'

  case "$1" in '-'|build|test|sh-test|bats )
      test -x "$(which bats)" || { install_bats || return $?; }
    ;; esac

  case "$1" in '-'|dev|build|check|test|git-versioning )
      test -x "$(which git-versioning)" || {
        install_git_versioning || return $?; }
    ;; esac

  case "$1" in -|project|jjb)
      test -x "$(which jenkins-jobs)" || {
        install_jjb || return $?; }
    ;; esac

  echo "OK. All pre-requisites for '$1' checked"
}

test "$(basename $0)" = "install-dependencies.sh" && {
  while test -n "$1"
  do
    main_entry "$1" || exit $?
    shift
  done
} || printf ""

# Id: jtb/0.0.4-dev install-dependencies.sh
