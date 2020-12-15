#!/usr/bin/env bash

set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output

current_branch() {
    local branch_name="$(git symbolic-ref HEAD 2>/dev/null)"
    branch_name=${branch_name##refs/heads/}
    echo $branch_name
}

number_untracked_files() {
    echo $(git status --porcelain 2>/dev/null| grep "^??" | wc -l)
}

uncommited_changes() {
    local changes=$(git diff-index --quiet HEAD --)
}

error() {
    printf "\n\e[33m\e[1m! ${1:-}\e[0m\n\n"
}

# fail if there are any untracked files
if [[ $(number_untracked_files) != "0" ]]; then
    error "Failing due to untracked files"
    git status
    exit 1
fi

# fail if there are any uncommited changes
if [[ -n "$(git status -s)" ]]; then
    error "Failing due to uncommited changes"
    git status
    exit 1
fi

# fail if we are not on the main branch
if [[ "$(current_branch)" != "main" ]]; then
    echo "You must be on the main branch to publish"
    exit 1
fi

# get any new tags from remote
git fetch --tags

# get the current version
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
version=$(echo $latest_tag | tr -d 'v')

# increment the version
next_version="v$((version + 1))"

read -p "Deploy as version: $next_version [y/n]? " choice
case "$choice" in
  y|Y ) echo "";;
  n|N ) exit 0;;
  * ) exit 1;;
esac

origin_main=$(git rev-parse origin/main)
echo "Tagging commit $origin_main with $next_version... "
git tag "$next_version" "${origin_main:?}"

git push --tags
