#!/bin/sh

test -n "$files" || files=tpl/base.yaml:jtb.yaml

jenkins-jobs test $files

# Id: jtb test.sh
