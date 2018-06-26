#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

# override this for testing while developing
TRAVIS_TAG="testing"

# if [[ $TRAVIS_EVENT_TYPE == "push" ]] && [[ -n $TRAVIS_TAG ]]; then

# Name the tarball
ARCHIVE_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$TRAVIS_TAG.tar.gz"
ARCHIVE_SHA_NAME="heroku-nodejs-plugin-node-$TRAVIS_NODE_VERSION-$TRAVIS_TAG.sha512"

echo "Saving build as $ARCHIVE_NAME"

# Compress the built directory into a tarball
tar -czf $ARCHIVE_NAME dist/

echo "Successfully created tar"    

# Generate a SHA and save that
sha512sum $ARCHIVE_NAME > $ARCHIVE_SHA_NAME

# Publish to github releases

npx publish-release --assets $ARCHIVE_NAME,$ARCHIVE_SHA_NAME --token $GITHUB_TOKEN --owner heroku --repo heroku-nodejs-plugin --tag $TRAVIS_TAG

# else
#     echo "Skipping deploy because event type is: $TRAVIS_EVENT_TYPE and git tag is: $TRAVIS_TAG"
# fi

