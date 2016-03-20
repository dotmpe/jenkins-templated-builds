#!/bin/sh

set -e

# For a detached HEAD git checkout (which is the Jenkins standard),
# generate a file with (additional) environment settings to be injected into a
# build.

scriptname=$(basename $0)

test -n "$1" || set -- .env-inject
test -n "$Branch_Default" || error "Env Branch_Default required" 1
test -n "$BUILD_NUMBER" || error "Jenkins env BUILD_NUMBER required" 1
test -n "$BUILD_VERSION" || {
  test -n "$VERSION_DOC" || VERSION_DOC="ReadMe.rst"
  test -e "$VERSION_DOC" || \
    error "env BUILD_VERSION or $VERSION_DOC with Version required" 1
  grep -q Version "$VERSION_DOC" || \
    error "env BUILD_VERSION or $VERSION_DOC with Version required" 1
}


note "Preparing env from detached GIT"

#GIT_CHECKOUT=$(git log -n 1 --pretty="format:%H")

git show-ref | grep -F "$GIT_COMMIT" | while read sha1 ref
do
  remote=$(basename $(dirname $ref))
  branch=$(basename $ref)
  info "Checkout corresponds to $remote/$branch"
  echo $remote/$branch >>.refs
  echo $branch >>.branches
done

SCM_REFS="$(sort -u .refs)"
BRANCHES="$(sort -u .branches)"
rm .refs .branches

GIT_COMMIT_ABBREV=${GIT_COMMIT:0:7}

# TODO: add feature tags to for differation in build, including the way the
# package version and/or build display name are build up.
#BUILD_ID=$JOB_NAME
#BUILD_ID=JTB-Upd
# FIXME: use git-versioning
test -n "$BUILD_VERSION" || BUILD_VERSION=$(grep Version ReadMe.rst | sed 's/[^0-9\.]//g')

test -z "$BUILD_CAUSE_SCMTRIGGER" && {

  git checkout $Branch_Default

  trueish "$Override_Branches" && {
    # Override branches
    BRANCHES="$Branch_Default"
  } || {
    BRANCHES="$BRANCHES $Branch_Default"
  }

  BUILD_TAG="build $BUILD_NUMBER manual"

} || {

  BUILD_TAG="build $BUILD_NUMBER"
}

BUILD_META="$BUILD_META $(echo $BRANCHES | tr " " "\n" | sort -u | tr "\n" " ")"

note "Generating Env-Inject properties"
for var in SCM_REFS BRANCHES GIT_COMMIT_ABBREV BUILD_ID BUILD_VERSION BUILD_TAG BUILD_META
do
  info "Exporting $var $(eval echo \$$var)"
  echo "$var = $(eval echo \$$var | sed 's/[\\ :\\,-]/\\&/')" >> $1
done


