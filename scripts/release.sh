#!/bin/bash

changes --scope macOS release --push --command 'gh release create $CHANGES_TAG --prerelease --title "$CHANGES_TITLE" --notes "$CHANGES_NOTES"'
