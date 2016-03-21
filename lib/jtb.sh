#!/bin/sh

set -e

# Id: jtb/0.0.2-master lib/jtb.sh


# Process all source files in $1:src/ into $2:dest/
jtb__process()
{
  test -n "$1" || error "No src" 1
  test -n "$2" || error "No dest" 1

  test -d "$1" || error "Should be dir: $1" 1
  test -d "$2" || error "Should be dir: $2" 1


  find $1 -iname '*.y*ml' | while read file
  do

    log "Processing $file src:$1 dest:$2"
    $JTB_SH_BIN/jtb.sh process-includes $file $1 $2 \
      || jtb_process_includes_parse_ret $?

  done
}

jtb_process_includes_parse_ret()
{
  case "$1" in
    0 ) log "Processed includes for $input $src" ;;
    1 ) err "arg error" ;;
    2 ) note "No includes for $file" ;;
    * ) error "unexpected" $1 ;;
  esac
}

# Process #include directives
jtb__process_includes()
{
  test -n "$1" || error "No inputfile" 1
  test -f "$1" || error "Should be file: $1" 1
  test -n "$2" || error "No srcdir" 1
  test -d "$2" || error "Should be dir: $2" 1
  test -n "$3" || set -- "$1" "$2" "/tmp/${scriptname}"
  test -d "$3" || mkdir -vp "$3"

  relinput="$(relpath "$1" "$2")"
  output="$3/$relinput"
  mkdir -vp $3/$(dirname $relinput)
  cp $1 $output

  grep -q '^#include' "$1" || exit 2

  while grep -q '^#include' $output
  do
    cp $output $output.tmp
    grep -n '^#include' $output | while read proc pathid
    do
      log "Including $pathid into $output"
      # XXX: bashism, test linenr=${proc//:*}
      linenr="$(echo "$proc" | cut -d ':' -f 1)"
      printf -- "\n" > $output
      head -n $(( $linenr - 1 )) $output.tmp >> $output
      include="$(relpath $2/$pathid)"
      test -s "$include" && {
        echo "# Start of include $include {{{" >> $output
        cat $include >> $output
        echo "# }}} End of include $include" >> $output
      } || {
        msg="Warning $0 unable to resolve $2 $pathid"
        warn "$msg"
        echo "# $msg" >> $output
      }
      tail -n +$(( $linenr + 1 )) $output.tmp >> $output
      rm $output.tmp
      break
    done
  done
}


jtb__update()
{
  test -n "$files" || files=$JTB_JJB_LIB/base.yaml:$JTB_HOME/jtb.yaml
  test -n "$test_out" || test_out=/tmp/jtb-test.out
  test -n "$test_err" || test_err=/tmp/jtb-test.err

  test -d "$(dirname $test_out)" || error "No such dir for $test_out" 1
  test -d "$(dirname $test_err)" || error "No such dir for $test_err" 1

  test -n "$DRY" || DRY=1
  test -n "$JJB_CONFIG" || JJB_CONFIG=/etc/jenkins_jobs/jenkins_jobs.ini

  flags=
  #flags="-l debug --ignore-cache "
  flags="--ignore-cache "
  test -e "$HOME/.jenkins_jobs.ini" && flags="$flags --conf $HOME/.jenkins_jobs.ini"

  #jenkins-jobs --version && {
  test -e $JJB_CONFIG && {

    test "$DRY" != "0" && {
      log " ** Dry-Run ** "
      jjb_update="echo DRY=$DRY jenkins-jobs update"
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
      error "errors during test ($test_err)"
      debugcat

    } || {

      log "Test OK. Starting update of files '$files'"
      $jjb_update $files && { \
          test "$DRY" != "1" && log "OK: Update complete" || log "OK: Dry-run complete"; } || \
        error "Update failed" 5

    }

  } || {

    echo ---------------------------------------------------------------------------
    log "ERROR: testing $files"
    debug
    debugcat
    warn "Please review $files" 11
  }
}


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


jtb__vars()
{
  python $JTB_SH_BIN/jenkins-template-build.py vars $@ || return $?
}

jtb__generate()
{
  python $JTB_SH_BIN/jenkins-template-build.py generate $@ || return $?
}

jtb__preset()
{
  python $JTB_SH_BIN/jenkins-template-build.py preset $@ || return $?
}

jtb__compile_tpl()
{
  test -e $1 || exit $?
  # take preset and JJB source yaml and output
  $JTB_SH_BIN/$scriptname preset $@ || return $?
}

jtb__compile_preset()
{
  verbosity=0 \
    $JTB_SH_BIN/$scriptname compile-tpl $JTB_SHARE/preset/$1.yaml $JTB_JJB_LIB/base.yaml \
          > $1.yaml || return $?
}


