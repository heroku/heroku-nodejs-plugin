#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

NODE_VERSION=$1

export GITHUB_TAG=${GITHUB_REF#/refs/tags/}

if [[ $GITHUB_REPOSITORY_OWNER == "heroku" ]] && [[ -n $GITHUB_TAG ]]; then
    # Name the tarball
    ARCHIVE_NAME="heroku-nodejs-plugin-node-$NODE_VERSION-$GITHUB_TAG.tar.gz"
    ARCHIVE_SHA_NAME="heroku-nodejs-plugin-node-$NODE_VERSION-$GITHUB_TAG.sha512"

    echo "Saving build as $ARCHIVE_NAME"

    # Compress the built directory into a tarball
    tar -czf $ARCHIVE_NAME "heroku-nodejs-plugin"
    # Generate a SHA and save that
    sha512sum $ARCHIVE_NAME > $ARCHIVE_SHA_NAME

    echo "Successfully created tar"    

    echo "Publishing binary"

    # Publish to github releases
    node ./scripts/upload-assets.js $ARCHIVE_NAME $ARCHIVE_SHA_NAME

    echo "Successfully uploaded assets"
else
    echo "Skipping deploy username is: $GITHUB_REPOSITORY_OWNER; and git tag is: $GITHUB_TAG"
fi

