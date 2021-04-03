#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

PROJECT_PATH="${ROOT_DIRECTORY}/document-finder/Fileaway.xcodeproj"

# TODO: Enable test builds if possible using a locally generated signing key.

# macOS
xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme Fileaway \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO
