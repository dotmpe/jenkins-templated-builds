#!/usr/bin/env bats

load helper
#base=jenkins-template-build.py
base=jtb.sh
init


@test "${bin} vars {name}-base-0" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -eq 0
}

@test "${bin} vars {name}-jtb-0" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -eq 0
}

@test "${bin} vars {name}-jtb-1" {
  run $BATS_TEST_DESCRIPTION
  test "$status" -eq 0
}

@test "${bin} generate {name}-base-0" "jtb_name=test" {
  export jtb_name=test
  run $BATS_TEST_DESCRIPTION
  test "$status" -eq 0
}

@test "${bin} preset" "preset/*" {
  export jtb_name=test
  for preset in preset/*.yaml
  do
    run $BATS_TEST_DESCRIPTION $preset
    test "$status" -eq 0
  done
}

