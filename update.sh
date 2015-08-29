#!/bin/sh

scriptname=update
version=0.0.0 # jtb

test -n "$files" || files=tpl/base.yaml:jtb.yaml
test -n "$test_err" || test_err=/tmp/jtb-test.err
test -n "$test_out" || test_out=/tmp/jtb-test.out

# stdio/stderr/exit util
log()
{
	[ -n "$(echo "$*")" ] || return 1;
	echo "[$scriptname.sh] $1"
}
err()
{
	[ -n "$(echo "$*")" ] || return 1;
	echo "$1 [$scriptname.sh]" 1>&2
	[ -n "$2" ] && exit $2
}


# Main

jenkins-job test $files 2> $err_out > $test_out && {
  test -s $err_out && {
    err "WARNING: errors during test ($err_out)"
  }
  test -s $test_out && {
    log "OK: Test output in $test_out."
    log "Starting update of files '$files'"
    jenkins-job update $files
    log "OK: Update complete"
  } || {
    log "XXX: need to scan stdout for test_out results, instead of test -s. And then fail:"
    err "FAIL: nothing generated" 1
  }
} || {
  err "ERROR: building $files" 1
}


