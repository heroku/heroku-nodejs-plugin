#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

export GITHUB_TAG=${GITHUB_REF#refs/tags/}

if [[ $GITHUB_REPOSITORY_OWNER == "heroku" ]] && [[ -n $GITHUB_TAG ]]; then
    echo "Creating GitHub release"

    node ./scripts/create-release.js

    echo "Successfully created release"
else
    echo "Skipping. Deploy username is: $GITHUB_REPOSITORY_OWNER; and git tag is: $GITHUB_TAG"
fi

