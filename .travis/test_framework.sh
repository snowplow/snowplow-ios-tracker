#!/usr/bin/env bash
set -e

PROJECT=$1
DEST_IOS=$2
SCHEME_IOS=$3
DEST_WATCH=$4
SCHEME_WATCH=$5

printf "\n\n Carthage bootstrap \n"
carthage bootstrap

printf "\n\n Test framework on iOS \n"
set -o pipefail && xcodebuild -destination "${DEST_IOS}" ${PROJECT} ${SCHEME_IOS} clean test | xcpretty

printf "\n\n Build framework on watchOS \n"
set -o pipefail && xcodebuild -destination "${DEST_WATCH}" ${PROJECT} ${SCHEME_WATCH} clean build | xcpretty
