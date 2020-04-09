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

BUILD_DEST_IOS="platform=iOS Simulator,OS=13.3,name=iPhone 11 Pro"
BUILD_DEST_PAIRED="platform=iOS Simulator,OS=13.3,name=iPhone 11 Pro"
BUILD_DEST_WATCH="platform=watchOS Simulator,OS=6.1.1,name=Apple Watch Series 5 - 44mm"

BUILD_PROJECT_LIB="-project Snowplow.xcodeproj"
BUILD_SCHEME_LIB_IOS="-scheme Snowplow-iOS"
BUILD_SCHEME_LIB_WATCH="-scheme Snowplow-watchOS"

BUILD_WORKSPACE_OBJC_DEMO="-workspace SnowplowDemo.xcworkspace"
BUILD_SCHEME_OBJC_DEMO="-scheme SnowplowDemo"

BUILD_WORKSPACE_SWIFT_DEMO="-workspace SnowplowSwiftDemo.xcworkspace"
BUILD_PROJECT_SWIFT_DEMO="-project SnowplowSwiftDemo.xcodeproj"
BUILD_SCHEME_SWIFT_DEMO_IOS="-scheme SnowplowSwiftDemo"
BUILD_SCHEME_SWIFT_DEMO_WATCH="-scheme SnowplowSwiftWatch"

BUILD_PROJECT_SWIFT_SPM_DEMO="-project SnowplowSwiftSPMDemo.xcodeproj"
BUILD_SCHEME_SWIFT_SPM_DEMO_IOS="-scheme SnowplowSwiftSPMDemo"


