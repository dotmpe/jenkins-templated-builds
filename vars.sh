#!/bin/sh

version=0.0.2-test # jtb

test -n "$files" || files="tpl/base.yaml:jtb.yaml"

test -n "$test_out" || test_out=/tmp/jtb-test.out
test -n "$test_err" || test_err=/tmp/jtb-test.err

test -d "$(dirname $test_out)" || error "No such dir for $test_out" 1
test -d "$(dirname $test_err)" || error "No such dir for $test_err" 1

# Id: jtb/0.0.2-test vars.sh

