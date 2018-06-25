#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

# delete /build and /dist if it exists
rm -rf build dist

# run the build using node-gyp
./node_modules/.bin/node-gyp configure build

# roll the javascript into one file
./node_modules/.bin/webpack-cli

# copy over the README
cp ./src/README.md ./dist/README.md

echo $(ls ./dist)
