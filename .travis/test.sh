#!/bin/sh

set -o pipefail
if [[ $PACKAGE_MANAGER == 'carthage' ]]; then
    # next command is broken up multiline for ease of editing
    xcodebuild -sdk iphonesimulator \
    -destination "${TEST_PLATFORM}" \
    -workspace Snowplow.xcworkspace \
    -scheme Snowplow \
    clean test \
    | xcpretty
elif [[ $PACKAGE_MANAGER == 'cocoapods' ]]; then
    xcodebuild -sdk iphonesimulator \
    -destination "${TEST_PLATFORM}" \
    -workspace Snowplow.xcworkspace \
    -scheme Snowplow \
    clean test \
    | xcpretty
fi
