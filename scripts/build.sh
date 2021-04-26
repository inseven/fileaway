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

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."
BUILD_DIRECTORY="${ROOT_DIRECTORY}/build"
TEMPORARY_DIRECTORY="${ROOT_DIRECTORY}/temp"

KEYCHAIN_PATH="${TEMPORARY_DIRECTORY}/temporary.keychain"
ARCHIVE_PATH="${BUILD_DIRECTORY}/Fileaway.xcarchive"
FASTLANE_ENV_PATH="${ROOT_DIRECTORY}/fastlane/.env"

# Generate a random string to secure the local keychain.
export TEMPORARY_KEYCHAIN_PASSWORD=`openssl rand -base64 14`

# Source the Fastlane .env file if it exists to make local development easier.
if [ -f "$FASTLANE_ENV_PATH" ] ; then
    echo "Sourcing .env..."
    source "$FASTLANE_ENV_PATH"
fi


function build_scheme {
    # Disable code signing for the build server.
    xcodebuild \
        -workspace Fileaway.xcworkspace \
        -scheme "$1" \
        clean \
        build \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO | xcpretty
}

cd "$ROOT_DIRECTORY"

# List the available schemes
xcodebuild -workspace Fileaway.xcworkspace -list

# Smoke test builds.

build_scheme "FileawayCore iOS"
build_scheme "FileawayCore macOS"
build_scheme "Fileaway iOS"
build_scheme "Fileaway macOS"

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
security create-keychain -p "$TEMPORARY_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"

# Determine the version and build number.
# TODO: Get Xcode to synthesise these itself so that builds also work there.
VERSION_NUMBER=`cat macos/version.txt | tr -d '[:space:]'`
GIT_COMMIT=`git rev-parse --short HEAD`
TIMESTAMP=`date +%s`
BUILD_NUMBER="${GIT_COMMIT}.${TIMESTAMP}"

# Import the certificates into our dedicated keychain.
bundler exec fastlane import_certificates keychain:"$KEYCHAIN_PATH"
security unlock-keychain -p "$TEMPORARY_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH"

# Archive and export the build.
KEYCHAIN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\""
xcodebuild -workspace Fileaway.xcworkspace -scheme "Fileaway macOS" -config Release -archivePath "$ARCHIVE_PATH"  OTHER_CODE_SIGN_FLAGS="$KEYCHAIN_FLAGS" BUILD_NUMBER=$BUILD_NUMBER MARKETING_VERSION=$VERSION_NUMBER archive
xcodebuild -archivePath "$ARCHIVE_PATH" -exportArchive -exportPath "$BUILD_DIRECTORY" -exportOptionsPlist "ExportOptions.plist"

APP_PATH="$BUILD_DIRECTORY/Fileaway.app"

# Show the code signing details.
codesign -dvv "$APP_PATH"

# Notarize the release build.
fastlane notarize_release package:"$APP_PATH"

# Archive the results.
pushd "$BUILD_DIRECTORY"
zip -r "Fileaway-macOS-${VERSION_NUMBER}-${BUILD_NUMBER}.zip" "."
popd
