#!/usr/bin/env bash

if [ "$CI" = true ]; then
	printf "\n\n Install Slather - Code coverage tool \n"
	gem install slather

	printf "\n\n Install Xcpretty - Prettify xcodebuild logs \n"
	gem install xcpretty -N --no-document

	printf "\n\n Install Cocoapods - Dependencies manager \n"
	gem install cocoapods -v '1.8.4'
fi

printf "\n\n Setup env variables \n"
BUILD_DEST="platform=iOS Simulator,OS=13.2.2,name=iPhone 8"
BUILD_PROJECT_LIB="-project Snowplow.xcodeproj"
BUILD_SCHEME_LIB="-scheme Snowplow-iOS"
BUILD_WORKSPACE_OBJC_DEMO="-workspace SnowplowDemo.xcworkspace"
BUILD_SCHEME_OBJC_DEMO="-scheme SnowplowDemo"
BUILD_WORKSPACE_SWIFT_DEMO="-workspace SnowplowSwiftDemo.xcworkspace"
BUILD_PROJECT_SWIFT_DEMO="-project SnowplowSwiftDemo.xcodeproj"
BUILD_SCHEME_SWIFT_DEMO="-scheme SnowplowSwiftDemo"
