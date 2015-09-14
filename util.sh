#!/bin/bash

set -e


# stdio/stderr/exit util
log()
{
  [ -n "$(echo "$*")" ] || return 1;
  echo "[$scriptname.sh] $1"
}
err()
{
  case "$(echo $1 | tr 'A-Z' 'a-z')" in
    warn*|err*|notice ) log "$1: $2" 1>&2 ;;
    * ) log "$2" 1>&2 ;;
  esac
  [ -z "$3" ] || exit $3
}

#boldred="$(tput bold)$(tput setaf 2)"
##boldred="\[\e[1;31m\]"
#purple="\033[0;35m"
#grey="\033[0;37m"
#yellow="\033[1;33m"
error()
{
  err "${boldred}Error" "${white}$1" "$2"
}
warn()
{
  err "${yellow}Warning" "${grey}$1" "$2"
}
note()
{
  err "${purple}Notice" "${grey}$1" "$2"
}
info()
{
  err " " "$1" "$2"
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

# XXX bash relpath - simple version, does not use common-base to create real
# relative paths
relpath()
{
  test -n "$1" || error "relpath" 1
  test -n "$2" || set -- "$1" "$(pwd)"

  local path="$(cleanpath "$1")" base="$(cleanpath "$2")" cpath="$(cleanpath)"
  relpath=${path:${#base}:$(( ${#path} - ${#base} ))}
  echo .$relpath
}
