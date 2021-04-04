#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

FILEAWAY_WORKSPACE_PATH="${ROOT_DIRECTORY}/Fileaway.xcworkspace"

# TODO: Enable test builds if possible using a locally generated signing key.

# Disable code signing for the build server.
export CODE_SIGN_IDENTITY=""
export CODE_SIGNING_REQUIRED=NO
export CODE_SIGNING_ALLOWED=NO
export DEVELOPMENT_TEAM=""

# FileActionsCore iOS
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "FileActionsCore iOS" \
    clean \
    build | xcpretty

# FileActionsCore macOS
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "FileActionsCore macOS" \
    clean \
    build | xcpretty

# iOS app
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "Fileaway iOS" \
    clean \
    build | xcpretty

# macOS app
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "Fileaway macOS" \
    clean \
    build | xcpretty
