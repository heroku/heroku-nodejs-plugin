#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

echo "Building plugin"

# delete /build and /heroku-nodejs-plugin if it exists
rm -rf build heroku-nodejs-plugin

# run the build using node-gyp
npx node-gyp configure build

# roll the javascript into one file
npx webpack-cli

echo "Successfully built plugin"
