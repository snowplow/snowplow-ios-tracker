#!/usr/bin/env bash

function ghexport {
	echo "::set-env name=$1::$2"
}

printf "\n\n Setup env variables \n"

BUILD_DEST_IOS="platform=iOS Simulator,OS=13.4.1,name=iPhone 11 Pro"
BUILD_DEST_PAIRED="platform=iOS Simulator,OS=13.4.1,name=iPhone 11 Pro"
BUILD_DEST_WATCH="platform=watchOS Simulator,OS=6.2,name=Apple Watch Series 5 - 44mm"

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

if [ "$CI" = true ]; then
	printf "\n\n Install Slather - Code coverage tool \n"
	gem install slather

	printf "\n\n Setup env variables for GH actions \n"
    
    ghexport BUILD_DEST_IOS "$BUILD_DEST_IOS"
    ghexport BUILD_DEST_PAIRED "$BUILD_DEST_PAIRED"
    ghexport BUILD_DEST_WATCH "$BUILD_DEST_WATCH"

    ghexport BUILD_PROJECT_LIB "$BUILD_PROJECT_LIB"
    ghexport BUILD_SCHEME_LIB_IOS "$BUILD_SCHEME_LIB_IOS"
    ghexport BUILD_SCHEME_LIB_WATCH "$BUILD_SCHEME_LIB_WATCH"

    ghexport BUILD_WORKSPACE_OBJC_DEMO "$BUILD_WORKSPACE_OBJC_DEMO"
    ghexport BUILD_SCHEME_OBJC_DEMO "$BUILD_SCHEME_OBJC_DEMO"

    ghexport BUILD_WORKSPACE_SWIFT_DEMO "$BUILD_WORKSPACE_SWIFT_DEMO"
    ghexport BUILD_PROJECT_SWIFT_DEMO "$BUILD_PROJECT_SWIFT_DEMO"
    ghexport BUILD_SCHEME_SWIFT_DEMO_IOS "$BUILD_SCHEME_SWIFT_DEMO_IOS"
    ghexport BUILD_SCHEME_SWIFT_DEMO_WATCH "$BUILD_SCHEME_SWIFT_DEMO_WATCH"

	ghexport BUILD_PROJECT_SWIFT_SPM_DEMO "$BUILD_WORKSPACE_OBJC_DEMO"
    ghexport BUILD_SCHEME_SWIFT_SPM_DEMO_IOS "$BUILD_SCHEME_OBJC_DEMO"
fi
