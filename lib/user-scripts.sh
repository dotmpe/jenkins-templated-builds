#!/bin/sh

set -e

# Id: jtb/0.0.2-master lib/user-scripts.sh


# XXX: for local dev use, may want multiple source repositories
jtb__build()
{
  mkdir -vp dist || return $?
	# republish from source
	$JTB_SH_BIN/$scriptname process tpl dist || return $?
}

jtb__test_preset()
{
  test -e $1 || exit $?
  test dist -nt tpl || {
		$JTB_SH_BIN/$scriptname build
  }
  $JTB_SH_BIN/$scriptname compile-preset $1 || return $?
  jenkins-jobs test $1.yaml:$JTB_JJB_LIB/base.yaml || return $?
}

