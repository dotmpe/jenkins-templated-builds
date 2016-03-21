#!/usr/bin/env bats

load helper
#base=jenkins-template-build.py
base=jtb.sh
init


@test "${bin} vars {name}-base-0" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -ne 1
}

@test "${bin} vars {name}-jtb-0" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -ne 1
}

@test "${bin} vars {name}-jtb-1" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -ne 1
}

@test "name=test ${bin} generate {name}-base-0" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -ne 1
}

@test "name=test ${bin} preset" "preset/*" {

  for preset in preset/*.yaml
  do
    run $BATS_TEST_DESCRIPTION $preset
    test "$status" -ne 1
  done
}

