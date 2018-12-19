#!/bin/sh

set -o pipefail

xcodebuild -sdk iphonesimulator \
-destination "${TEST_PLATFORM}" \
-project Snowplow.xcodeproj \
-scheme Snowplow-iOS \
clean test \
| xcpretty
