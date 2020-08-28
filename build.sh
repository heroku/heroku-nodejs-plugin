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

# copy over the README
cp ./src/README.md ./heroku-nodejs-plugin/README.md
echo { \"type\": \"commonjs\" } > ./heroku-nodejs-plugin/package.json

echo "Successfully built plugin"
