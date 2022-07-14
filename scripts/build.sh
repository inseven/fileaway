#!/bin/bash

# Copyright (c) 2018-2021 InSeven Limited
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail
set -x
set -u

SCRIPTS_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ROOT_DIRECTORY="${SCRIPTS_DIRECTORY}/.."
BUILD_DIRECTORY="${ROOT_DIRECTORY}/build"
TEMPORARY_DIRECTORY="${ROOT_DIRECTORY}/temp"

KEYCHAIN_PATH="${TEMPORARY_DIRECTORY}/temporary.keychain"
ARCHIVE_PATH="${BUILD_DIRECTORY}/Fileaway.xcarchive"
FASTLANE_ENV_PATH="${ROOT_DIRECTORY}/fastlane/.env"

CHANGES_DIRECTORY="${SCRIPTS_DIRECTORY}/changes"
BUILD_TOOLS_DIRECTORY="${SCRIPTS_DIRECTORY}/build-tools"

CHANGES_GITHUB_RELEASE_SCRIPT="${CHANGES_DIRECTORY}/examples/gh-release.sh"

PATH=$PATH:$CHANGES_DIRECTORY
PATH=$PATH:$BUILD_TOOLS_DIRECTORY

IOS_XCODE_PATH=${IOS_XCODE_PATH:-/Applications/Xcode.app}
MACOS_XCODE_PATH=${MACOS_XCODE_PATH:-/Applications/Xcode.app}

source "${SCRIPTS_DIRECTORY}/environment.sh"

# Check that the GitHub command is available on the path.
which gh || (echo "GitHub cli (gh) not available on the path." && exit 1)

# Process the command line arguments.
POSITIONAL=()
RELEASE=${TRY_RELEASE:-false}
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -r|--release)
        RELEASE=true
        shift
        ;;
        *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done

# iPhone to be used for smoke test builds and tests.
# This doesn't specify the OS version to allow the build script to recover from minor build changes.
IPHONE_DESTINATION="platform=iOS Simulator,name=iPhone 12 Pro"

# Generate a random string to secure the local keychain.
export TEMPORARY_KEYCHAIN_PASSWORD=`openssl rand -base64 14`

# Source the Fastlane .env file if it exists to make local development easier.
if [ -f "$FASTLANE_ENV_PATH" ] ; then
    echo "Sourcing .env..."
    source "$FASTLANE_ENV_PATH"
fi

function xcode_project {
    xcodebuild \
        -workspace Fileaway.xcworkspace "$@"
}

function build_scheme {
    # Disable code signing for the build server.
    xcode_project \
        -scheme "$1" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO "${@:2}" | xcpretty
}

cd "$ROOT_DIRECTORY"

# List the available schemes.
xcode_project -list

# Smoke test builds.

# iOS
sudo xcode-select --switch "$IOS_XCODE_PATH"
build_scheme "FileawayCore iOS" clean build build-for-testing test \
    -sdk iphonesimulator \
    -destination "$IPHONE_DESTINATION"
build_scheme "Fileaway iOS" clean build

# macOS
sudo xcode-select --switch "$MACOS_XCODE_PATH"
build_scheme "FileawayCore macOS" clean build build-for-testing test

# Build the macOS archive.

# Clean up the build directory.
if [ -d "$BUILD_DIRECTORY" ] ; then
    rm -r "$BUILD_DIRECTORY"
fi
mkdir -p "$BUILD_DIRECTORY"

# Create the a new keychain.
if [ -d "$TEMPORARY_DIRECTORY" ] ; then
    rm -rf "$TEMPORARY_DIRECTORY"
fi
mkdir -p "$TEMPORARY_DIRECTORY"
echo "$TEMPORARY_KEYCHAIN_PASSWORD" | build-tools create-keychain "$KEYCHAIN_PATH" --password

function cleanup {

    # Cleanup the temporary files and keychain.
    cd "$ROOT_DIRECTORY"
    build-tools delete-keychain "$KEYCHAIN_PATH"
    rm -rf "$TEMPORARY_DIRECTORY"

    # Clean up any private keys.
    if [ -f ~/.appstoreconnect/private_keys ]; then
        rm -r ~/.appstoreconnect/private_keys
    fi
}

trap cleanup EXIT

# Determine the version and build number.
VERSION_NUMBER=`changes --scope macOS version`
GIT_COMMIT=`git rev-parse --short HEAD`
TIMESTAMP=`date +%s`
BUILD_NUMBER="${GIT_COMMIT}.${TIMESTAMP}"

# Import the certificates into our dedicated keychain.
bundle exec fastlane import_certificates keychain:"$KEYCHAIN_PATH"

# Build and archive the macOS project.
sudo xcode-select --switch "$MACOS_XCODE_PATH"
xcode_project \
    -scheme "Fileaway macOS" \
    -config Release \
    -archivePath "$ARCHIVE_PATH" \
    OTHER_CODE_SIGN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\"" \
    BUILD_NUMBER=$BUILD_NUMBER \
    MARKETING_VERSION=$VERSION_NUMBER \
    clean archive | xcpretty
xcodebuild \
    -archivePath "$ARCHIVE_PATH" \
    -exportArchive \
    -exportPath "$BUILD_DIRECTORY" \
    -exportOptionsPlist "macos/ExportOptions.plist"

APP_BASENAME="Fileaway.app"
APP_PATH="$BUILD_DIRECTORY/$APP_BASENAME"

# Attempt to create a version tag and publish a GitHub release; fails quietly if there's no new release.
if $RELEASE ; then

    # Install the private key.
    mkdir -p ~/.appstoreconnect/private_keys/
    echo -n "$APPLE_API_KEY" | base64 --decode -o ~/".appstoreconnect/private_keys/AuthKey_${APPLE_API_KEY_ID}.p8"

    changes \
        --scope macOS \
        release \
        --skip-if-empty \
        --push \
        --exec "${CHANGES_GITHUB_RELEASE_SCRIPT}" \
        "${BUILD_DIRECTORY}/${ZIP_BASENAME}"


fi
