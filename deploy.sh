#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

# override this for testing while developing
TRAVIS_TAG="latest"

# if [[ $TRAVIS_EVENT_TYPE == "push" ]] && [[ -n $TRAVIS_TAG ]]; then
echo $(ls .)
echo $(pwd)

# Name the tarball
ARCHIVE_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$TRAVIS_TAG.tar.gz"

echo "archive name: $ARCHIVE_NAME"

echo $(ls $TRAVIS_BUILD_DIR/dist)

# Compress the built directory into a tarball
tar -czf $ARCHIVE_NAME dist/

echo "Successfully created tar"    

# Generate a SHA and save that

# Publish to github releases

# else
#     echo "Skipping deploy because event type is: $TRAVIS_EVENT_TYPE and git tag is: $TRAVIS_TAG"
# fi

