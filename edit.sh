#!/bin/sh

test -n "$files" || files="tpl/base.yaml jtb.yaml"

$EDITOR $files

# Id: jtb/0.0.2-master edit.sh
