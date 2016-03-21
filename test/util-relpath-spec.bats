#!/usr/bin/env bats

load helper
base=boilerplate
init


@test "${lib} relpath - should ..." {

	test "$(relpath preset/gh-juc.yaml ../)" = "./jenkins-templated-builds/preset/gh-juc.yaml"
	test "$(relpath preset/gh-juc.yaml preset)" = "./gh-juc.yaml"

}

