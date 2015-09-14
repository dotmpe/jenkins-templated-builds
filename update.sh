#!/bin/sh

scriptname=update
version=0.0.2-test # jtb

. ./util.sh

test -n "$files" || files=dist/base.yaml:jtb.yaml
test -n "$test_out" || test_out=/tmp/jtb-test.out
test -n "$test_err" || test_err=/tmp/jtb-test.err

test -d "$(dirname $test_out)" || error "No such dir for $test_out" 1
test -d "$(dirname $test_err)" || error "No such dir for $test_err" 1

test -n "$DRY" || DRY=1
test -n "$JJB_CONFIG" || JJB_CONFIG=/etc/jenkins_jobs/jenkins_jobs.ini

flags="-l debug"
test -e "$HOME/.jenkins_jobs.ini" && flags="$flags --conf $HOME/.jenkins_jobs.ini"


debug()
{
  info "files=$files"
  info "test_out=$test_out"
  info "test_err=$test_err"
  info "jjb_update=$jjb_update"
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
    jjb_update="jenkins-jobs $flags update"
  }

} || {

  log "Not a jenkins env. Not running update"

  jjb_update="echo NO-OP jenkins-jobs $flags update"

  debug
}

# Naive routines for testing
jenkins-jobs $flags test $files 2> $test_err > $test_out && {

  jobs="$(echo $(grep -i builder.job.name $test_err | cut -d ':' -f 4))"
  count="$(grep -i number.of.jobs.generated $test_err | cut -d ':' -f 4)"
  log "Generated $count jobs: $jobs"

  grep -i 'exception' $test_err && {
    log "Test stderr/stdout in $test_err/$test_out."
    echo ---------------------------------------------------------------------------
    error "errors during test ($test_err)" 12
    debugcat

  } || {

    log "Test OK. Starting update of files '$files'"
    $jjb_update $files && \
      log "OK: Update complete" || \
      error "Update failed" 5

  }

} || {

  echo ---------------------------------------------------------------------------
  log "ERROR: testing $files"
  debug
  debugcat
  exit 11
}


# Id: jtb/0.0.2-test update.sh
