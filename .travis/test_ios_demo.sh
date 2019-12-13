#!/usr/bin/env bash

APP=$1
DEP_FILE=$2
DEST=$3
PROJECT=$4
SCHEME=$5

if [ $DEP_FILE == "Cartfile" ]; then
	printf "\n\n Carthage update \n"
	cd Examples/$APP
	./generateCartfile.sh
    carthage update --platform ios
elif [ $DEP_FILE == "Podfile" ]; then
	printf "\n\n Pod update \n"
	cd Examples/$APP
	pod update
elif [[ $DEP_FILE == Podfile* ]]; then
	printf "\n\n Pod update with Podfile: " + $DEP_FILE + " \n"
	cp -rf .travis/$DEP_FILE Examples/$APP/Podfile
	cd Examples/$APP
	pod update
else
	printf "ERROR: Podfile or Cartfile is not correctly indicated" 1>&2
	exit 1
fi

printf "\n\n Test ${APP} \n"
set -o pipefail && xcodebuild -sdk iphonesimulator -destination "${DEST}" ${PROJECT} ${SCHEME} clean build | xcpretty
