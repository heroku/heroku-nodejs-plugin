#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

echo "Building plugin"

# delete /build and /dist if it exists
rm -rf build dist

# run the build using node-gyp
npx node-gyp configure build

# roll the javascript into one file
npx webpack-cli

# copy over the README
cp ./src/README.md ./dist/README.md

echo "Successfully built plugin"
