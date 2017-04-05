#!/bin/sh

set -e

version=0.0.4-dev # jtb


# Process all source files in $1:src/ into $2:dest/
jtb__process()
{
  test -n "$1" || error "No src" 1
  test -n "$2" || error "No dest" 1

  test -d "$1" || error "Should be dir: $1" 1
  test -d "$2" || error "Should be dir: $2" 1

  # Process includes on every YAML from $1:src/
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
  test -z "$4" || error "surplus arguments: '$4'" 1


  # Read includes from source

  relinput="$(relpath ${1} ${2})"
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
      linenr="$(echo "$proc" | cut -d ':' -f 1)"
      printf -- "\n" > $output
      head -n $(( $linenr - 1 )) $output.tmp >> $output
      input=$2/$pathid
      test -s "$input" && {
        echo "# Start of include $input {{{" >> $output
        cat $input >> $output
        echo "# }}} End of include $input " >> $output
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
  test -z "$2" || error "surplus arguments '$2'" 1
  test -n "$1" && {
    files=$JTB_JJB_LIB/base.yaml:$1
  } || {
    test -n "$files" || files=$JTB_JJB_LIB/base.yaml:$JTB_HOME/jtb.yaml
  }
  test -n "$test_out" || test_out=/tmp/jtb-test.out
  test -n "$test_err" || test_err=/tmp/jtb-test.err

  test -d "$(dirname $test_out)" || error "No such dir for $test_out" 1
  test -d "$(dirname $test_err)" || error "No such dir for $test_err" 1

  test -n "$DRY" || DRY=1
  test -n "$JJB_CONFIG" || {
    test -e "$HOME/.jenkins_jobs.ini" && JJB_CONFIG=~/.jenkins_jobs.ini ||
    JJB_CONFIG=/etc/jenkins_jobs/jenkins_jobs.ini
  }

  flags=
  #flags="-l debug --ignore-cache "
  # FIXME --allow-empty-variables should not be needed with proper templates
  # and would allow for better, more useful tests
  flags="--ignore-cache --allow-empty-variables"

	debug "Usings flag = $flags"

  #jenkins-jobs --version && {
  test -e $JJB_CONFIG && {
	  debug "Using JJB_CONFIG = $JJB_CONFIG"
    flags="$flags --conf $JJB_CONFIG"

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


jtb__usage()
{
  test -z "$1" || error "surplus arguments '$1'" 1
  cat <<EOF
Jenkins-Templated-Builds (for Jenkins Job Builder).

Usage:
  jtb.sh vars TPL       Print variable placeholders for template.
  jtb.sh generate TPL_ID JJB_FILES...
                        Process JJB tpl. of given name, resolves placeholders
                        from env.
  jtb.sh preset PRESET_FILE JJB_FILES...
                        Generate JJB file from JTB preset file and JJB file(s)
                        with templates.
  jtb.sh compile-tpl    XXX: alias for preset?
  jtb.sh compile-preset PRESET_ID
                        Like 'preset', but accepts only the basename of a file
                        in the 'presets' folder. And uses dist/base.yaml as
                        JJB template file.

  jtb.sh update JTB_FILES...
                        Convenience route to test JTB files, and use the
                        resulting JJB file with jenkins-job test or update.

  jtb.sh process SRC_DIR DEST_DIR
                        Process partial JTB files.



EOF
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
  test -n "$1" || error "preset name required '$1'" 1
  # take preset and JJB source yaml and output
  test -e $1 || exit $?
  python $JTB_SH_BIN/jenkins-template-build.py preset $@ || return $?
}

jtb__compile_tpl()
{
  test -e $1 || exit $?
  # call self; take preset and JJB source yaml and output
  $JTB_SH_BIN/$scriptname preset $@ || return $?
}

jtb__compile_preset()
{
  test -n "$1" || error "preset name required '$1'" 1
  test -z "$2" || error "surplus arguments '$2'" 1
  verbosity=0 \
    $JTB_SH_BIN/$scriptname preset $JTB_SHARE/preset/$1.yaml $JTB_JJB_LIB/base.yaml \
          > $1.yaml || return $?
}

jtb__update_jtb()
{
  test -n "$1" -a -e "$1" || error "preset file name required '$1'" 1
  test -z "$2" || error "surplus arguments '$2'" 1
  local name="$(basename "$(basename "$1" .yaml)" .yml)"
  (
    jtb__preset "$1" > ${name}-jjb.yml
    jtb__update "${name}-jjb.yml"
  ) || return $?
}

# Id: jtb/0.0.4-dev lib/jtb.sh
