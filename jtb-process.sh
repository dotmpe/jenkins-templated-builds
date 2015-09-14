#!/bin/sh

set -e

scriptname=jtb-process

# Process all source files in $src/ into $dest/

src=$1
dest=$2

. ./util.sh

test -n "$src" || error "No src" 1
test -n "$dest" || error "No dest" 1

test -d "$src" || error "Should be dir: $src" 1
test -d "$dest" || error "Should be dir: $dest" 1


parse_ret()
{
  case "$1" in
    0 ) log "Processed includes for $input $src" ;;
    1 ) err "arg error" ;;
    2 ) note "No includes for $file" ;; 
    * ) error "unexpected" $1 ;;
  esac
}

find $src -iname '*.y*ml' | while read file
do

  cp $file $dest
  ./jtb-process-includes.sh $file $src $dest || parse_ret $?

done


