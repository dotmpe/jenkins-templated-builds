#!/bin/sh

# Id: jtb/0.0.3-dev lib/util.sh


# stdio/stderr/exit util
# 1:msg 2:exit
err()
{
  log "$1" 1>&2
  [ -z "$2" ] || exit $2
}

# 1:msg 2:exit
log()
{
  test -n "$verbosity" && std_v 1 || return 0
	[ -n "$(echo $*)" ] || return 1;
  key=$scriptname
  test -n "$subcmd" && key=${key}${bb}:${bk}${subcmd}
  echo "[$key] $1"
}

# 1:tag 2:msg 3:exit
logh()
{
  err "$2" $3
}

case "$TERM" in
	""|dumb ) ;;
	* )
boldred="$(tput bold)$(tput setaf 2)"
##boldred="\[\e[1;31m\]"
#purple="\033[0;35m"
#grey="\033[0;37m"
#yellow="\033[1;33m"
		;;
esac

# std-v <level>
# if verbosity is defined, return non-zero if <level> is below verbosity treshold
std_v()
{
  test -z "$verbosity" && return || {
    test $verbosity -ge $1 && return || return 1
  }
}

std_exit()
{
  test "$1" != "0" -a -z "$1" && return 1 || exit $1
}

error()
{
  std_v 3 || std_exit $2 || return 0
  logh "${boldred}Error" "${white}$1" $2
}
warn()
{
  std_v 4 || std_exit $2 || return 0
  logh "${yellow}Warning" "${grey}$1" $2
}
note()
{
  std_v 5 || std_exit $2 || return 0
  logh "${purple}Notice" "${grey}$1" $2
}
info()
{
  std_v 6 || std_exit $2 || return 0
  logh "Info" "$1" $2
}
debug()
{
  std_v 7 || std_exit $2 || return 0
  logh "Debug" "$1" $2
}

# demonstrate log levels
std_demo()
{
  scriptname=std subcmd=demo
  log "Log line"
  err "Log line"
  error "Log line"
  warn "Foo bar"
  note "Foo bar"
  info "Foo bar"
  debug "Foo bar"

  for x in warn note info debug
    do
      $x "testing $x out"
    done
}


cleanpath()
{
  test -n "$1" || set -- "$(pwd)"
  test -d "$1" && {
    cd $1; pwd; return
  }
  test -f "$1" && {
    cd $(dirname $1); echo $(pwd)/$(basename $1); return
  } || {
    error "no path $1" 1
  }
}

relpath()
{
  test -n "$1" || error "relpath" 1
  test -n "$2" || set -- "$1" "$(pwd)"

  local path="$(cleanpath "$1")" base="$(cleanpath "$2")" cpath="$(cleanpath)"

  diag "1=$1 path=$path"
  diag "$(( ${#base} + 1 )) ${#path}"

  local relpath=$(echo ${path} | cut -c $(( ${#base} + 1 ))-${#path} )

  echo .$relpath
}

trueish()
{
  test -n "$1" || return 1
  case "$1" in
    on|true|yes|1)
      return 0;;
    * )
      return 1;;
  esac
}

var_id()
{
  echo "$@" | sed 's/[^A-Za-z0-9_]/_/g'
}

