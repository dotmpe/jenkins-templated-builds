#!/usr/bin/env bash

# JTB dep installer for travis
# Id: jtb install-dependencies.sh

source ./util.sh

install_jjb()
{
  log "Cloning JJB.."
  git clone https://git.openstack.org/openstack-infra/jenkins-job-builder $HOME/build/jjb

  log "Installing JJB.."
  pushd $HOME/build/jjb
  #sudo python setup.py install
  python setup.py install --user
  popd


  log "JJB install complete. Testing.."
  jenkins-jobs --version

  log "JJB install OK"
}

