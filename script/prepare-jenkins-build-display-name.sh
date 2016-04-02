#!/bin/sh

set -e

# Given BUILD_{VERSION,TAG,META} and $BRANCHES
# write a build-display-name for Jenkins to use to ${1:-.build-name}

scriptname=$(basename $0)

test -n "$1" || set -- .build-name


note "Generating Build-Name file"

info "Current Build-Name: $BUILD_DISPLAY_NAME"

#BUILD_DISPLAY_NAME="$BUILD_ID/$BUILD_VERSION"
BUILD_DISPLAY_NAME="$BUILD_VERSION"

test -z "$BUILD_TAG" \
  || BUILD_DISPLAY_NAME="$BUILD_DISPLAY_NAME-$(echo $BUILD_TAG | sed 's/[^a-zA-Z0-9]\{1,\}/-/g')"
test -z "$BUILD_META" \
  || BUILD_DISPLAY_NAME="$BUILD_DISPLAY_NAME+$(echo $BUILD_META | sed 's/[^a-zA-Z0-9]\{1,\}/+/g')"

info "New Build-Name: $BUILD_DISPLAY_NAME"
echo $BUILD_DISPLAY_NAME > $1


# Id: jtb/0.0.3-dev
