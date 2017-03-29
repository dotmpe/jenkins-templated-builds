#!/bin/sh

set -e

# For a detached HEAD git checkout (which is the Jenkins standard),
# generate a file with (additional) environment settings to be injected into a
# build.

scriptname=$(basename $0)


test -n "$Branch_Default" || error "Env Branch_Default required" 1
test -n "$BUILD_NUMBER" || error "Jenkins env BUILD_NUMBER required" 1
test -n "$BUILD_VERSION" || {
  test -n "$VERSION_DOC" || VERSION_DOC="ReadMe.rst"
  test -e "$VERSION_DOC" || \
    error "env BUILD_VERSION or $VERSION_DOC with Version required" 1
  grep -q Version "$VERSION_DOC" || \
    error "env BUILD_VERSION or $VERSION_DOC with Version required" 1
}
test -n "$BUILD_DIR" || BUILD_DIR=build
test -n "$git_abbrev" || git_abbrev=7
# Set outputfile
test -n "$1" || set -- $BUILD_DIR/env-inject.properties


note "Preparing env from detached GIT"

mkdir -vp $BUILD_DIR

## Get current parameters from GIT and env

GIT_CHECKOUT="$(git log -1 --format="%H")"
GIT_COMMIT_ABBREV=$(echo "${GIT_CHECKOUT}" | cut -c 1-$git_abbrev )

test "$GIT_COMMIT" = "$GIT_CHECKOUT" && \
  info "No custom commit version ($GIT_COMMIT_ABBREV)" || \
  note "Commit changed from $(echo "$GIT_COMMIT" | cut -c 1-$git_abbrev ) to $GIT_COMMIT_ABBREV"

#GIT_CHECKOUT=$(git log -n 1 --pretty="format:%H")

# Get names for current commit, both lists local branch name and remote ref
refs=$BUILD_DIR/scm-references.list
branches=$BUILD_DIR/scm-branches.list
echo > $refs && echo > $branches
git show-ref | grep -F "$GIT_CHECKOUT" | while read sha1 ref
do
  remote=$(basename $(dirname $ref))
  branch=$(basename $ref)
  info "Checkout corresponds to $remote/$branch"
  echo $remote/$branch >>$refs
  echo $branch >>$branches
done
SCM_REFS="$(echo $(sort -u $refs))"
BRANCHES="$(echo $(sort -u $branches))"

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

# Options: use branch name(s) either as build-tag, or build-meta, or not.
test -n "$Build_Display_Name_Branch" || Build_Display_Name_Branch=build-tag-prepend
case "$Build_Display_Name_Branch" in

  build-tag-prepend )
      test -z "$BRANCHES" || \
        BUILD_TAG="$(echo $BRANCHES | sed 's/ /  /g')  $BUILD_TAG"
    ;;

  meta-tag-append )
      test -z "$BRANCHES" || \
        BUILD_META="$BUILD_META  $(echo $BRANCHES | sed 's/ /  /g')"
    ;;

esac


# Build tag now contains version markers, ie. RC1 or alpha et. al.
# Meta tag has other markers, those not influencing version directly.

# Keep all tags in a raw form
RAW_TAGS="$RAW_TAGS  $(echo "$BUILD_TAG  $BUILD_META" | sed 's/\> \</-/g')"

# Combine both tag sets with BUILD_DISPLAY_NAME
test -z "$BUILD_TAG" || BUILD_DISPLAY_NAME="$BUILD_DISPLAY_NAME-$(
  echo "$BUILD_TAG" | sed 's/  /-/g' | sed 's/ //g')"

test -z "$BUILD_META" || BUILD_DISPLAY_NAME="$BUILD_DISPLAY_NAME+$(
  echo "$BUILD_META" | sed 's/  /+/g' | sed 's/ //g')"


# Abbreviate build-name tags a bit
BUILD_DISPLAY_NAME="$(echo $BUILD_DISPLAY_NAME | sed -E '
    s/\>(.)git/\1g/
    s/\>(.)patch/\1p/
    s/\>(.)build/\1b/
  ')"



## Prepare env injection properties file with new variables

info "Generating Env-Inject properties"
for var in SCM_REFS BRANCHES GIT_CHECKOUT GIT_COMMIT_ABBREV BUILD_ID BUILD_VERSION BUILD_TAG BUILD_META
do
  info "Exporting $var $(eval echo \$$var)"
  echo "$var = $(eval echo \$$var | sed 's/[\\ :\\,-]/\\&/g')" >> $1
done


# Id: jtb/0.0.4-dev script/prepare-detached-git-version-env.sh
