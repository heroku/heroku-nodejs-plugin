#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

echo $(ls dist)
echo $TRAVIS_TAG
echo $TRAVIS_NODE_VERSION
echo $TRAVIS_EVENT_TYPE
echo $TRAVIS_COMMIT_MESSAGE


# - ARCHIVE_NAME="$TRAVIS_NODE_VERSION-${TRAVIS_TAG:-latest}-$TRAVIS_OS_NAME-`uname -m`.tar"
# - $TRAVIS_BUILD_DIR/build.sh
# - tar --create --verbose --file="$ARCHIVE_NAME" --directory "$TRAVIS_BUILD_DIR/dist"