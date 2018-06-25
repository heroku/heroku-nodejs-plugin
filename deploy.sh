#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

if [[ $TRAVIS_EVENT_TYPE == "push" ]] && [[ -n $TRAVIS_TAG ]]; then
    ARCHIVE_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$TRAVIS_TAG.tar"
    tar --create --verbose --file="$ARCHIVE_NAME" --directory "$TRAVIS_BUILD_DIR/dist"

    echo "Successfully created tar"    
    echo $(ls .)
else
    echo "Skipping deploy because event type is: $TRAVIS_EVENT_TYPE and git tag is: $TRAVIS_TAG"
fi

