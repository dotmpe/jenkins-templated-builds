#!/bin/sh

scriptname=update
version=0.0.0 # jtb

. ./util.sh

test -n "$files" || files=tpl/base.yaml:jtb.yaml
test -n "$test_err" || test_err=$HOME/tmp/jtb-test.err
test -n "$test_out" || test_out=$HOME/tmp/jtb-test.out

test -d "$(dirname test_out)" || err "No such dir for $test_out" 1
test -d "$(dirname test_out)" || err "No such dir for $test_err" 1



# Main

test -n "$JENKINS_HOME" && {
  log "Running actual update"
  jjb_update="jenkins-jobs update"
} || {
  log "Not a jenkins env. Not running update"
  jjb_update="echo jenkins-jobs update"
}

jenkins-jobs test $files 2> $test_err > $test_out && {
  test -s $test_err && {
    err "WARNING: errors during test ($test_err)"
  }
  test -s $test_out && {
    log "OK: Test output in $test_out."
    log "Starting update of files '$files'"
    $jjb_update $files
    log "OK: Update complete"
  } || {
    log "XXX: need to scan stdout for test_out results, instead of test -s. And then fail:"
    err "FAIL: nothing generated" 1
  }
} || {
  err "ERROR: building $files" 1
}


