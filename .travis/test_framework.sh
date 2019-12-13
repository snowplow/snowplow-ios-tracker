#!/usr/bin/env bash

DEST=$1
PROJECT=$2
SCHEME=$3

printf "\n\n Carthage bootstrap \n"
carthage bootstrap --platform iOS

printf "\n\n Test framework \n"
set -o pipefail && xcodebuild -sdk iphonesimulator -destination "${DEST}" ${PROJECT} ${SCHEME} clean test | xcpretty
