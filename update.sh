#!/bin/sh

scriptname=update
version=0.0.2-master # jtb


. ./util.sh

test -n "$files" || files=tpl/base.yaml:jtb.yaml
test -n "$test_out" || test_out=/tmp/jtb-test.out
test -n "$test_err" || test_err=/tmp/jtb-test.err

test -d "$(dirname $test_out)" || err "No such dir for $test_out" 1
test -d "$(dirname $test_err)" || err "No such dir for $test_err" 1

debug()
{
  err files=$files
  err test_out=$test_out
  err test_err=$test_err
}


# Main

test -n "$JJB_Dry_Yun" && {
  log "Running actual update"
  jjb_update="jenkins-jobs update"
} || {
  log "Not a jenkins env. Not running update"
  jjb_update="echo jenkins-jobs update"

  debug
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
    echo ---------------------------------------------------------------------------
    err "FAIL: nothing generated" 1
  }
} || {
  echo ---------------------------------------------------------------------------
  err "ERROR: building $files"
  debug

  echo Test output: --------------------------------------------------------------
  cat $test_out | fold -w 80

  echo Test errors: --------------------------------------------------------------
  cat $test_err | fold -w 80
  echo ---------------------------------------------------------------------------

  exit 1
}


# Id: jtb/0.0.2-master update.sh
