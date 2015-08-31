#!/bin/sh

test -n "$files" || files="tpl/base.yaml jtb.yaml"

$EDITOR $files

# Id: jtb/0.0.2-test edit.sh
