#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."

function build_scheme {
    # Disable code signing for the build server.
    # TODO: Enable test builds if possible using a locally generated signing key.
    # export CODE_SIGN_IDENTITY=""
    # export CODE_SIGNING_REQUIRED=NO
    # export CODE_SIGNING_ALLOWED=NO
    # export DEVELOPMENT_TEAM=""
    xcodebuild \
        -workspace Fileaway.xcworkspace \
        -scheme "$1" \
        clean \
        build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO | xcpretty
}

# Clean up derived data (mostly for GitHub's benefit).
# rm -rf ~/Library/Developer/Xcode/DerivedData

cd "$ROOT_DIRECTORY"
xcodebuild -workspace Fileaway.xcworkspace -list  # List schemes
build_scheme "FileawayCore iOS"
build_scheme "FileawayCore macOS"
build_scheme "Fileaway iOS"
build_scheme "Fileaway macOS"
