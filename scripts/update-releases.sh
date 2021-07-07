#!/bin/bash

set -e
set -o pipefail
set -x
set -u

scripts_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
root_directory="${scripts_directory}/.."
fileaway_directory="${root_directory}/fileaway"
changes_directory="${fileaway_directory}/scripts/changes"

changes_path="${changes_directory}/changes"
changes_pipfile_path="${changes_directory}/Pipfile"
releases_template_path="${root_directory}/templates/releases.markdown"
releases_path="${root_directory}/docs/releases/index.markdown"

cd "$root_directory"

if [ ! -d "$fileaway_directory" ] ; then
    git clone https://github.com/inseven/fileaway.git
fi

cd "$fileaway_directory"
git fetch origin --prune --prune-tags
git checkout origin/main
git submodule update --init --recursive

PIPENV_PIPFILE="$changes_pipfile_path" pipenv install
"$changes_path" --scope macOS notes --all --released --template "$releases_template_path" > "$releases_path"
