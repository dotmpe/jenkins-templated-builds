

type stdfail >/dev/null 2>&1 || {
  stdfail()
  {
    test -n "$1" || set -- "Unexpected. Status"
    fail "$1: $status, output(${#lines[@]}) is '${lines[*]}'"
  }
}

type pass >/dev/null 2>&1 || {
  pass() # a noop() variant..
  {
    return 0
  }
}

type test_ok_empty >/dev/null 2>&1 || {
  test_ok_empty()
  {
    test ${status} -eq 0 && test -z "${lines[*]}"
  }
}

type test_ok_nonempty >/dev/null 2>&1 || {
  test_ok_nonempty()
  {
    test ${status} -eq 0 && test -n "${lines[*]}" && {
      test -z "$1" || fnmatch "$1" "${lines[*]}"
    }
  }
}

noop()
{
  printf -- ""
}


# Set env and other per-specfile init
test_init()
{
  test -n "$base" || exit 12
  test -n "$uname" || uname=$(uname)
  hostname_init
}

hostname_init()
{
  hostnameid="$(hostname -s | tr 'A-Z.-' 'a-z__')"
}

# Std test_init and setting script exec var `bin` based on PREFIX
init_bin()
{
  # Global test if PREFIX isset
  test -z "$PREFIX" && bin=./bin/$base || bin=$PREFIX/bin/$base
}

# Std test_init for script lib var `lib`
init_lib()
{
  # XXX path to shared files
  #test -z "$PREFIX" && share=script || share=$PREFIX/share/misc/jjb/$base/
  #test -z "$PREFIX" && share=dist || share=$PREFIX/share/misc/jjb/$base/
  test -z "$PREFIX" && lib=./lib || lib=$PREFIX/lib/$base/
}

init()
{
  test_init
  test -x bin/$base && {
    init_bin
  }
  init_lib

  . $lib/util.sh
  #. $lib/main.sh
  #main_init

  # XXX does this overwrite bats load?
  #. main.init.sh
}


### Helpers for conditional tests
# currently usage is to mark test as skipped or 'TODO' per test case, based on
# host. Written into the specs itself.

# XXX: Hardcorded list of test envs, for use as is-skipped key
current_test_env()
{
  test -n "$TEST_ENV" && { echo $TEST_ENV ; return; }
  test -n "$hostnameid" || hostname_init
  case " $test_env_hosts " in
    *" $hostname "* )
      echo $hostname ;;
    * )
      echo $test_env_other ;;
  esac
}

# Check if test is skipped. Currently works based on hostname and above values.
check_skipped_envs()
{
  # XXX hardcoded envs
  local skipped=0
  test -n "$1" || set -- "$(hostname -s | tr 'A-Z_.-' 'a-z___')" "$(whoami)"
  cur_env=$(current_test_env)
  for env in $@
  do
    is_skipped $env && {
        test "$cur_env" = "$env" && {
            skipped=1
        }
    } || continue
  done
  return $skipped
}

# Returns successful if given key is not marked as skipped in the env
# Specifically return 1 for not-skipped, unless $1_SKIP evaluates to non-empty.
is_skipped()
{
  local key="$(echo "$1" | tr 'a-z._-' 'A-Z___')"
  local skipped="$(echo $(eval echo \$${key}_SKIP))"
  test -n "$skipped" && return
  return 1
}


### Misc. helper functions

next_temp_file()
{
  test -n "$pref" || pref=script-mpe-test-
  local cnt=$(echo $(echo /tmp/${pref}* | wc -l) | cut -d ' ' -f 1)
  next_temp_file=/tmp/$pref$cnt
}

lines_to_file()
{
  # XXX: cleanup
  echo "status=${status}"
  echo "#lines=${#lines[@]}"
  echo "lines=${lines[*]}"
  test -n "$1" && file=$1
  test -n "$file" || { next_temp_file; file=$next_temp_file; }
  echo file=$file
  local line_out
  echo "# test/helper.bash $(date)" > $file
  for line_out in "${lines[@]}"
  do
    echo $line_out >> $file
  done
}

tmpf()
{
  tmpd || return $?
  tmpf=$tmpd/$BATS_TEST_NAME-$BATS_TEST_NUMBER
  test -z "$1" || tmpf="$tmpf-$1"
}

tmpd()
{
  tmpd=$BATS_TMPDIR/bats-tempd
  test -d "$tmpd" && rm -rf $tmpd
  mkdir -vp $tmpd
}

