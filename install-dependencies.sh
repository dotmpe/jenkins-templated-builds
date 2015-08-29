#!/usr/bin/env bash

# JTB dep installer for travis
# Id: jtb install-dependencies.sh

source ./util.sh

install_jjb()
{
  log "Cloning JJB.."
  git clone https://git.openstack.org/openstack-infra/jenkins-job-builder $HOME/build/jjb \
    || err "Error cloning to $HOME/build/jjb" 1

  log "Installing JJB.."
  pushd $HOME/build/jjb
  #sudo python setup.py install
  python setup.py install --user \
    && log "JJB install complete" \
    || err "Error during JJB installation" 1
  popd

  jenkins-jobs --version && {
    log "JJB install OK"
  } || {
    err "JJB installation invalid" 1
  }
}

