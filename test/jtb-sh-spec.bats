#!/usr/bin/env bats

load helper
base=jtb.sh
init_bin


@test "${bin} vars {name}-base-0" {
  run $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} vars {name}-jtb-0" {
  run $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} vars {name}-jtb-1" {
  run $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} generate {name}-base-0" "jtb_name=test" {
  export jtb_name=test
  run $BATS_TEST_DESCRIPTION
  test_ok_nonempty || stdfail
}

@test "${bin} preset" "preset/*" {
  export jtb_name=test failed=/tmp/jtb-py-spec.failed failout=/tmp/jtb-py-spec.out 
  for preset in preset/*.yaml
  do
    run $BATS_TEST_DESCRIPTION $preset
    test_ok_nonempty && diag "OK: $preset" || {
      { echo "Failed for preset: $preset ($status):"
        echo "${lines[@]}"
      } >>$failout
      echo $preset >>$failed
    }
  done
  test -s "$failed" && {
    diag "$(cat $failout || noop)"
    rm $failed $failout || noop
    fail "presets failed: $(cat $failed)"
  } || noop
}

