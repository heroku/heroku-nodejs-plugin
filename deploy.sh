#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

NODE_VERSION=$1

if [[ $CIRCLE_PROJECT_USERNAME == "heroku" ]] && [[ -n $CIRCLE_TAG ]]; then
    # Name the tarball
    ARCHIVE_NAME="heroku-nodejs-plugin-node-$NODE_VERSION-$CIRCLE_TAG.tar.gz"
    ARCHIVE_SHA_NAME="heroku-nodejs-plugin-node-$NODE_VERSION-$CIRCLE_TAG.sha512"

    echo "Saving build as $ARCHIVE_NAME"

    # Compress the built directory into a tarball
    tar -czf $ARCHIVE_NAME "heroku-nodejs-plugin-$NODE_VERSION/"
    # Generate a SHA and save that
    sha512sum $ARCHIVE_NAME > $ARCHIVE_SHA_NAME

    echo "Successfully created tar"    

    echo "Publishing binary"

    # Publish to github releases
    node ./scripts/release.js $ARCHIVE_NAME $ARCHIVE_SHA_NAME

    echo "Successfully published released"
else
    echo "Skipping deploy username is: $CIRCLE_PROJECT_USERNAME; and git tag is: $CIRCLE_TAG"
fi

