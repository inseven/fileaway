#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

FILEAWAY_PROJECT_PATH="${ROOT_DIRECTORY}/macos/Fileaway.xcodeproj"
FILE_ACTIONS_WORKSPACE_PATH="${ROOT_DIRECTORY}/FileActions.xcworkspace"

# TODO: Enable test builds if possible using a locally generated signing key.

# Fileaway

# macOS app
xcodebuild \
    -project "$FILEAWAY_PROJECT_PATH" \
    -scheme Fileaway \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty

# File Actions

# iOS app
xcodebuild \
    -workspace "$FILE_ACTIONS_WORKSPACE_PATH" \
    -scheme "File Actions iOS" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty

# FileActionsCore iOS
xcodebuild \
    -workspace "$FILE_ACTIONS_WORKSPACE_PATH" \
    -scheme "FileActionsCore iOS" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty

# FileActionsCore macOS
xcodebuild \
    -workspace "$FILE_ACTIONS_WORKSPACE_PATH" \
    -scheme "FileActionsCore macOS" \
    clean \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO | xcpretty
