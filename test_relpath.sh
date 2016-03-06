#!/bin/bash

. ./util.sh
set -e

test "$(relpath preset/gh-juc.yaml ../)" = "./jenkins-templated-builds/preset/gh-juc.yaml"
test "$(relpath preset/gh-juc.yaml preset)" = "./gh-juc.yaml"

