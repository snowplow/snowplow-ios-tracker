#!/bin/sh

set -o pipefail

xcodebuild -sdk iphonesimulator \
-destination "${TEST_PLATFORM}" \
-workspace Snowplow.xcworkspace \
-scheme Snowplow-iOS \
clean test \
| xcpretty
