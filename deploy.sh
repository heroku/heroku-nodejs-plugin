#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

if [[ $TRAVIS_EVENT_TYPE == "push" ]] && [[ -n $TRAVIS_TAG ]]; then
    # Name the tarball
    ARCHIVE_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$TRAVIS_TAG.tar.gz"
    ARCHIVE_SHA_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$TRAVIS_TAG.sha512"

    echo "Saving build as $ARCHIVE_NAME"

    # Compress the built directory into a tarball
    tar -czf $ARCHIVE_NAME dist/
    # Generate a SHA and save that
    sha512sum $ARCHIVE_NAME > $ARCHIVE_SHA_NAME

    echo "Successfully created tar"    

    # Publish to github releases

    echo "Publishing binary"    

    npx github-release upload \
    --owner heroku \
    --repo heroku-nodejs-plugin \
    --token $GITHUB_TOKEN \
    --tag $TRAVIS_TAG \
    --name $TRAVIS_TAG \
    --body $TRAVIS_TAG \
    $ARCHIVE_NAME $ARCHIVE_SHA_NAME
else
    echo "Skipping deploy because event type is: $TRAVIS_EVENT_TYPE and git tag is: $TRAVIS_TAG"
fi

