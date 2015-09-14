#!/bin/sh

scriptname=update
version=0.0.2-test # jtb

. ./util.sh

test -n "$files" || files=dist/base.yaml:jtb.yaml
test -n "$test_out" || test_out=/tmp/jtb-test.out
test -n "$test_err" || test_err=/tmp/jtb-test.err

test -d "$(dirname $test_out)" || err "No such dir for $test_out" 1
test -d "$(dirname $test_err)" || err "No such dir for $test_err" 1

test -n "$DRY" || DRY=1
test -n "$JJB_CONFIG" || JJB_CONFIG=/etc/jenkins_jobs/jenkins_jobs.ini


debug()
{
  err files=$files
  err test_out=$test_out
  err test_err=$test_err
}

debugcat()
{
  echo Test output: --------------------------------------------------------------
  cat $test_out | fold -w 80

  echo Test errors: --------------------------------------------------------------
  cat $test_err | fold -w 80
  echo ---------------------------------------------------------------------------
}


### Main

#jenkins-jobs --version && {
test -e $JJB_CONFIG && {

  test "$DRY" != "0" && {
    log " ** Dry-Run ** "
    jjb_update="echo DRY-RUN jenkins-jobs update"
  } || {
    log "Running actual update"
    jjb_update="jenkins-jobs update"
  }

} || {

  log "Not a jenkins env. Not running update"
  jjb_update="echo NO-OP jenkins-jobs update"

  debug
}

# Naive routines for testing
jenkins-jobs test $files 2> $test_err > $test_out && {
  grep -i 'error\|exception' $test_err && {
    err "errors during test ($test_err)" 1
  }
  jobs="$(echo $(grep -i builder.job.name $test_err | cut -d ':' -f 4))"
  count="$(grep -i number.of.jogs.generated $test_err | cut -d ':' -f 4)"
  log "Generated $count jobs: $jobs"

  test -s $test_out && {
    log "Test OK. Starting update of files '$files'"
    $jjb_update $files
    log "OK: Update complete"
  } || {
    log "Updated failed. Test stderr/stdout in $test_err/$test_out."
    debug_cat
    exit 12
  }

} || {
  echo ---------------------------------------------------------------------------
  err "ERROR: testing $files"
  debug
  debug_cat
  exit 11
}


# Id: jtb/0.0.2-test update.sh
