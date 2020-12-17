#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

if [[ $CIRCLE_PROJECT_USERNAME == "heroku" ]] && [[ -n $CIRCLE_TAG ]]; then
    echo "Creating GitHub release"

    node ./scripts/create-release.js

    echo "Successfully created release"
else
    echo "Skipping deploy username is: $CIRCLE_PROJECT_USERNAME; and git tag is: $CIRCLE_TAG"
fi

