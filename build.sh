#!/usr/bin/env bash
# bin/compile <heroku-stack>

STACK=${1:-}

# delete /build and /dist if it exists
rm -rf build dist

# run the build using node-gyp
./node_modules/.bin/node-gyp configure build

# roll the javascript into one file
./node_modules/.bin/webpack-cli

# copy over the README
cp ./src/README.md ./dist/README.md

echo $STACK

exit 0