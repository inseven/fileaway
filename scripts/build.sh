#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

# TODO: Enable test builds if possible using a locally generated signing key.

# Disable code signing for the build server.
# export CODE_SIGN_IDENTITY=""
# export CODE_SIGNING_REQUIRED=NO
# export CODE_SIGNING_ALLOWED=NO
# export DEVELOPMENT_TEAM=""

# Clean up derived data (mostly for GitHub's benefit).
rm -rf ~/Library/Developer/Xcode/DerivedData

# Set the working directory.
cd "$ROOT_DIRECTORY"

# List the available schemes.
xcodebuild -workspace Fileaway.xcworkspace -list

function build_scheme {
    xcodebuild \
        -workspace Fileaway.xcworkspace \
        -scheme "$1" \
        clean \
        build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO | xcpretty
}

build_scheme "FileawayCore iOS"
build_scheme "FileawayCore macOS"
build_scheme "Fileaway iOS"
build_scheme "Fileaway macOS"
