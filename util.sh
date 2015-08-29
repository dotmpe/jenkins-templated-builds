#!/bin/sh

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


