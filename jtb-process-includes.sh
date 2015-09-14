#!/bin/bash

# Process #include directives

scriptname=jtb-process-includes

. ./util.sh

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
    linenr=${proc//:*}
    echo -n > $output
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

