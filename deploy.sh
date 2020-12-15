#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

if [[ $CIRCLE_BRANCH == "main" ]] && [[ -n $CIRCLE_TAG ]]; then
    # Name the tarball
    ARCHIVE_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$CIRCLE_TAG.tar.gz"
    ARCHIVE_SHA_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$CIRCLE_TAG.sha512"

    echo "Saving build as $ARCHIVE_NAME"

    # Compress the built directory into a tarball
    tar -czf $ARCHIVE_NAME heroku-nodejs-plugin/
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
    echo "Skipping deploy because branch is: $CIRCLE_BRANCH; and git tag is: $CIRCLE_TAG"
fi

