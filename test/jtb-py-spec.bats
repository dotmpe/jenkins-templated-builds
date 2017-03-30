#!/usr/bin/env bats

load helper
base=jenkins-template-build.py
init_bin


# As jtb-sh-spec but without Sh wrapper

setup()
{
  test -n "$JTB_HOME" || JTB_HOME=.
  test -n "$ENV" || ENV=$JTB_HOME/bin/env.sh
  . $ENV
}

@test "${bin} vars {name}-base-0" {
  run python $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} vars {name}-jtb-0" {
  run python $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} vars {name}-jtb-1" {
  run python $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} generate {name}-base-0" "jtb_name=test" {
  export jtb_name=test
  run python $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} preset" "preset/*" {
  skip "TODO: JTB-5 see jtb-sh-spec.bats"
}

