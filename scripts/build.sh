#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

FILEAWAY_WORKSPACE_PATH="${ROOT_DIRECTORY}/Fileaway.xcworkspace"

# TODO: Enable test builds if possible using a locally generated signing key.

# FileActionsCore iOS
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "FileActionsCore iOS" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty

# FileActionsCore macOS
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "FileActionsCore macOS" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty

# iOS app
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "File Actions iOS" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty

# macOS app
xcodebuild \
    -workspace "$FILEAWAY_WORKSPACE_PATH" \
    -scheme "Fileaway" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty
