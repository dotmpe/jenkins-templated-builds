#!/bin/sh

test -n "$files" || files="tpl/base.yaml jtb.yaml"

$EDITOR $files

# Id: jtb edit.sh
