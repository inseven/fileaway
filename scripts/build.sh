#!/bin/bash

# Copyright (c) 2018-2025 Jason Morley
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
MACOS_ARCHIVE_PATH="${BUILD_DIRECTORY}/Fileaway-macOS.xcarchive"
IOS_ARCHIVE_PATH="${BUILD_DIRECTORY}/Fileaway-iOS.xcarchive"
ENV_PATH="${ROOT_DIRECTORY}/.env"

RELEASE_SCRIPT_PATH="${SCRIPTS_DIRECTORY}/release.sh"

IOS_XCODE_PATH=${IOS_XCODE_PATH:-/Applications/Xcode.app}
MACOS_XCODE_PATH=${MACOS_XCODE_PATH:-/Applications/Xcode.app}

source "${SCRIPTS_DIRECTORY}/environment.sh"

# Check that the GitHub command is available on the path.
which gh || (echo "GitHub cli (gh) not available on the path." && exit 1)

# Process the command line arguments.
POSITIONAL=()
RELEASE=${RELEASE:-false}
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

# Generate a random string to secure the local keychain.
export TEMPORARY_KEYCHAIN_PASSWORD=`openssl rand -base64 14`

# Source the .env file if it exists to make local development easier.
if [ -f "$ENV_PATH" ] ; then
    echo "Sourcing .env..."
    source "$ENV_PATH"
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
        CODE_SIGNING_ALLOWED=NO "${@:2}"
}

cd "$ROOT_DIRECTORY"

# List the available schemes.
xcode_project -list

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
VERSION_NUMBER=`changes version`
BUILD_NUMBER=`build-tools generate-build-number`

# Import the certificates into our dedicated keychain.
echo "$APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD" | build-tools import-base64-certificate --password "$KEYCHAIN_PATH" "$APPLE_DISTRIBUTION_CERTIFICATE_BASE64"
echo "$DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD" | build-tools import-base64-certificate --password "$KEYCHAIN_PATH" "$DEVELOPER_ID_APPLICATION_CERTIFICATE_BASE64"

# Install the provisioning profiles.
build-tools install-provisioning-profile "profiles/Fileaway_App_Store_Profile.mobileprovision"
build-tools install-provisioning-profile "profiles/Fileaway_Mac_App_Store_Profile.provisionprofile"
build-tools install-provisioning-profile "profiles/Fileaway_Developer_ID_Profile.provisionprofile"

# Build and test FileawayCore.
pushd "core"
sudo xcode-select --switch "$MACOS_XCODE_PATH"
xcodebuild -scheme FileawayCore -destination "platform=macOS" clean build test
sudo xcode-select --switch "$IOS_XCODE_PATH"
xcodebuild -scheme FileawayCore -destination "$DEFAULT_IPHONE_DESTINATION" clean build test
popd

# Build, test and archive the iOS project.
sudo xcode-select --switch "$IOS_XCODE_PATH"
xcode_project \
    -scheme "Fileaway iOS" \
    -destination "$DEFAULT_IPHONE_DESTINATION" \
    clean build build-for-testing test
xcode_project \
    -scheme "Fileaway iOS" \
    -config Release \
    -archivePath "$IOS_ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    OTHER_CODE_SIGN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\"" \
    CURRENT_PROJECT_VERSION=$BUILD_NUMBER \
    MARKETING_VERSION=$VERSION_NUMBER \
    clean archive
xcodebuild \
    -archivePath "$IOS_ARCHIVE_PATH" \
    -exportArchive \
    -exportPath "$BUILD_DIRECTORY" \
    -exportOptionsPlist "ios/ExportOptions.plist"

# Build and archive the macOS project.
sudo xcode-select --switch "$MACOS_XCODE_PATH"
xcode_project \
    -scheme "Fileaway macOS" \
    -config Release \
    -archivePath "$MACOS_ARCHIVE_PATH" \
    OTHER_CODE_SIGN_FLAGS="--keychain=\"${KEYCHAIN_PATH}\"" \
    CURRENT_PROJECT_VERSION=$BUILD_NUMBER \
    MARKETING_VERSION=$VERSION_NUMBER \
    clean archive
xcodebuild \
    -archivePath "$MACOS_ARCHIVE_PATH" \
    -exportArchive \
    -exportPath "$BUILD_DIRECTORY" \
    -exportOptionsPlist "macos/ExportOptions.plist"

# Apple recommends we use ditto to prepare zips for notarization.
# https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow
RELEASE_BASENAME="Fileaway-$VERSION_NUMBER-$BUILD_NUMBER"
RELEASE_ZIP_BASENAME="$RELEASE_BASENAME.zip"
RELEASE_ZIP_PATH="$BUILD_DIRECTORY/$RELEASE_ZIP_BASENAME"
pushd "$BUILD_DIRECTORY"
/usr/bin/ditto -c -k --keepParent "Fileaway.app" "$RELEASE_ZIP_BASENAME"
rm -r "Fileaway.app"
popd

IPA_PATH="$BUILD_DIRECTORY/Fileaway.ipa"

# Install the private key.
mkdir -p ~/.appstoreconnect/private_keys/
API_KEY_PATH=~/".appstoreconnect/private_keys/AuthKey_${APPLE_API_KEY_ID}.p8"
echo -n "$APPLE_API_KEY_BASE64" | base64 --decode -o "$API_KEY_PATH"

# Validate the iOS build.
xcrun altool --validate-app \
    -f "${IPA_PATH}" \
    --apiKey "$APPLE_API_KEY_ID" \
    --apiIssuer "$APPLE_API_KEY_ISSUER_ID" \
    --output-format json \
    --type ios

# Notarize the macOS app.
xcrun notarytool submit "$RELEASE_ZIP_PATH" \
    --key "$API_KEY_PATH" \
    --key-id "$APPLE_API_KEY_ID" \
    --issuer "$APPLE_API_KEY_ISSUER_ID" \
    --output-format json \
    --wait | tee command-notarization-response.json
NOTARIZATION_ID=`cat command-notarization-response.json | jq -r ".id"`
NOTARIZATION_RESPONSE=`cat command-notarization-response.json | jq -r ".status"`

xcrun notarytool log \
    --key "$API_KEY_PATH" \
    --key-id "$APPLE_API_KEY_ID" \
    --issuer "$APPLE_API_KEY_ISSUER_ID" \
    "$NOTARIZATION_ID" | tee "$BUILD_DIRECTORY/notarization-log.json"

if [ "$NOTARIZATION_RESPONSE" != "Accepted" ] ; then
    echo "Failed to notarize app."
    exit 1
fi

# Archive the build directory.
ZIP_BASENAME="build-${VERSION_NUMBER}-${BUILD_NUMBER}.zip"
ZIP_PATH="${BUILD_DIRECTORY}/${ZIP_BASENAME}"
pushd "${BUILD_DIRECTORY}"
zip -r "${ZIP_BASENAME}" .
popd

if $RELEASE ; then

    changes \
        release \
        --skip-if-empty \
        --pre-release \
        --push \
        --exec "${RELEASE_SCRIPT_PATH}" \
        "${IPA_PATH}" "${ZIP_PATH}"

fi
