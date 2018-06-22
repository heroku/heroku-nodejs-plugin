#!/usr/bin/env bash
# bin/compile <heroku-stack> <node-version>

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

STACK=${1:-}
NODE_VERSION=${2:-}

apt-get update -y
apt-get install g++ -y

echo $(which g++)

install_nodejs() {
  local version=${1:-8.x}
  local dir="$2"

  echo "Resolving node version $version..."
  if ! read number url < <(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=$version" "https://nodebin.herokai.com/v1/node/$platform/latest.txt"); then
    echo "Failed to install Node for version: $NODE_VERSION";
    exit 1;
  fi

  echo "Downloading and installing node $number..."
  local code=$(curl "$url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/node.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "Unable to download Node: $code"
    exit 1;
  fi
  tar xzf /tmp/node.tar.gz -C /tmp
  rm -rf $dir/*
  mv /tmp/node-v$number-$os-$cpu/* $dir
  chmod +x $dir/bin/*
}

get_os() {
  uname | tr A-Z a-z
}

get_cpu() {
  if [[ "$(uname -p)" = "i686" ]]; then
    echo "x86"
  else
    echo "x64"
  fi
}

# Get info about the environment
os=$(get_os)
cpu=$(get_cpu)
platform="$os-$cpu"

# delete /build and /dist if it exists
rm -rf build dist bin

# if node and npm is undefined, install the specified version
if ! type "node" > /dev/null 2> /dev/null; then
    mkdir bin
    install_nodejs $NODE_VERSION ./bin
    export PATH=./bin/bin:$PATH 
fi

# install node modules
if [[ ! -d "node_modules" ]]; then
    npm install
fi

echo $PATH
echo $(which g++)
echo $(which gcc)

# run the build using node-gyp
./node_modules/.bin/node-gyp configure build

# roll the javascript into one file
./node_modules/.bin/webpack-cli

# copy over the README
cp ./src/README.md ./dist/README.md

echo $(ls ./dist)

exit 0


