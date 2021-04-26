#!/bin/bash

set -e
set -o pipefail
set -x
set -u

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."
BUILDS_DIRECTORY="${ROOT_DIRECTORY}/builds"

KEYCHAIN_PATH="${ROOT_DIRECTORY}/temporary.keychain"
ARCHIVE_PATH="${BUILDS_DIRECTORY}/Fileaway.xcarchive"
FASTLANE_ENV_PATH="${ROOT_DIRECTORY}/fastlane/.env"

# TODO: Source the env file if it exists?

if [ -f "$FASTLANE_ENV_PATH" ] ; then
    echo "Sourcing .env..."
    source "$FASTLANE_ENV_PATH"
fi


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

cd "$ROOT_DIRECTORY"

#xcodebuild -workspace Fileaway.xcworkspace -list  # List schemes
#build_scheme "FileawayCore iOS"
#build_scheme "FileawayCore macOS"
#build_scheme "Fileaway iOS"
#build_scheme "Fileaway macOS"

# Build the macOS archive.

# Clean up the build directory.
if [ -d "$BUILDS_DIRECTORY" ] ; then
    rm -r "$BUILDS_DIRECTORY"
fi
mkdir -p "$BUILDS_DIRECTORY"

# Determine the version and build number.
# TODO: Get Xcode to synthesise these itself so that builds also work there.
VERSION_NUMBER=`cat macos/version.txt | tr -d '[:space:]'`
GIT_COMMIT=`git rev-parse --short HEAD`
TIMESTAMP=`date +%s`
BUILD_NUMBER="${GIT_COMMIT}.${TIMESTAMP}"

# Import the certificates into a dedicated keychain.
fastlane init_keychain
security unlock-keychain -p "$TEMPORARY_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH"

# Archive and export the build.
KEYCHAIN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\""
xcodebuild -workspace Fileaway.xcworkspace -scheme "Fileaway macOS" -config Release -archivePath "$ARCHIVE_PATH"  OTHER_CODE_SIGN_FLAGS="$KEYCHAIN_FLAGS" BUILD_NUMBER=$BUILD_NUMBER MARKETING_VERSION=$VERSION_NUMBER archive
xcodebuild -archivePath "$ARCHIVE_PATH" -exportArchive -exportPath "$BUILDS_DIRECTORY" -exportOptionsPlist "ExportOptions.plist"

# Show the code signing details.
codesign -dvv "$BUILDS_DIRECTORY/Fileaway.app"

# Notarize the release build.
fastlane notarize_release

# Archive the results.
pushd "$BUILDS_DIRECTORY"
zip -r "Fileaway-macOS-${VERSION_NUMBER}-${BUILD_NUMBER}.zip" "."
popd
