#!/usr/bin/env bash

# JTB dep installer for travis
# Id: jtb install-dependencies.sh


install_jjb()
{
  git clone https://git.openstack.org/openstack-infra/jenkins-job-builder $HOME/build/jjb

  pushd $HOME/build/jjb
  #sudo python setup.py install
  python setup.py install --user
  popd

  jenkins-jobs --version
}

