#!/bin/bash

set -e
set -o pipefail
set -x

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ROOT_DIRECTORY="${SCRIPT_DIRECTORY}/.."
BUILDS_DIRECTORY="${ROOT_DIRECTORY}/builds"

KEYCHAIN_PATH="${ROOT_DIRECTORY}/temporary.keychain"
ARCHIVE_PATH="${BUILDS_DIRECTORY}/Fileaway.xcarchive"

# TODO: Source the env file if it exists?


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

#xcodebuild -workspace Fileaway.xcworkspace -list  # List schemes
#build_scheme "FileawayCore iOS"
#build_scheme "FileawayCore macOS"
#build_scheme "Fileaway iOS"
#build_scheme "Fileaway macOS"

# Build the macOS archive.

if [ -d "$BUILDS_DIRECTORY" ] ; then
    rm -r "$BUILDS_DIRECTORY"
fi
mkdir -p "$BUILDS_DIRECTORY"

security unlock-keychain -p "$TEMPORARY_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

xcodebuild -workspace Fileaway.xcworkspace -scheme "Fileaway macOS" -config Release -archivePath "$ARCHIVE_PATH" OTHER_CODE_SIGN_FLAGS='--keychain="$KEYCHAIN_PATH"' archive
xcodebuild -archivePath "$ARCHIVE_PATH" -exportArchive -exportPath "$BUILDS_DIRECTORY" -exportOptionsPlist "ExportOptions.plist"

codesign -dvv "$BUILDS_DIRECTORY/Fileaway.app"

pushd "$BUILDS_DIRECTORY"
zip "Fileaway.zip" "Fileaway.app"
popd
