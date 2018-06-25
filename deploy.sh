#!/usr/bin/env bash

echo $(ls dist)
echo $TRAVIS_TAG
echo $TRAVIS_NODE_VERSION


# - ARCHIVE_NAME="$TRAVIS_NODE_VERSION-${TRAVIS_TAG:-latest}-$TRAVIS_OS_NAME-`uname -m`.tar"
# - $TRAVIS_BUILD_DIR/build.sh
# - tar --create --verbose --file="$ARCHIVE_NAME" --directory "$TRAVIS_BUILD_DIR/dist"