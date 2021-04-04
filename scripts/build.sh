#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

# TODO: Enable test builds if possible using a locally generated signing key.

# Disable code signing for the build server.
export CODE_SIGN_IDENTITY=""
export CODE_SIGNING_REQUIRED=NO
# export CODE_SIGNING_ALLOWED=NO
export DEVELOPMENT_TEAM=""

# Clean up derived data (mostly for GitHub's benefit).
rm -rf ~/Library/Developer/Xcode/DerivedData

# Set the working directory.
cd "$ROOT_DIRECTORY"

# List the available schemes.
xcodebuild -workspace Fileaway.xcworkspace -list

# FileawayCore iOS
xcodebuild \
    -workspace Fileaway.xcworkspace \
    -scheme "FileawayCore iOS" \
    clean \
    build | xcpretty

# FileawayCore macOS
xcodebuild \
    -workspace Fileaway.xcworkspace \
    -scheme "FileawayCore macOS" \
    clean \
    build | xcpretty

# iOS app
xcodebuild \
    -workspace Fileaway.xcworkspace \
    -scheme "Fileaway iOS" \
    clean \
    build | xcpretty

# macOS app
xcodebuild \
    -workspace Fileaway.xcworkspace \
    -scheme "Fileaway macOS" \
    clean \
    build | xcpretty
