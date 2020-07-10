#!/usr/bin/env bash
set -e

APP=$1
DEP_FILE=$2
PROJECT=$3
DEST_IOS=$4
SCHEME_IOS=$5
DEST_WATCH=$6
SCHEME_WATCH=$7

if [ $DEP_FILE == "Cartfile" ]; then
	printf "\n\n Carthage update \n"
	cd Examples/$APP
	./generateCartfile.sh
	carthage update
elif [ $DEP_FILE == "SPM" ]; then
	printf "\n\n Swift Package Manager \n"
	cd Examples/$APP	
elif [ $DEP_FILE == "Podfile" ]; then
	printf "\n\n Pod update \n"
	cd Examples/$APP
	pod update
elif [[ $DEP_FILE == Podfile* ]]; then
	printf "\n\n Pod update with Podfile: " + $DEP_FILE + " \n"
	cp -rf .scripts/$DEP_FILE Examples/$APP/Podfile
	cd Examples/$APP
	pod update
else
	printf "ERROR: Podfile or Cartfile is not correctly indicated" 1>&2
	exit 1
fi

printf "\n\n Build iOS ${APP} \n"
set -o pipefail && xcodebuild -destination "${DEST_IOS}" ${PROJECT} ${SCHEME_IOS} clean build | xcpretty

if [ ! -z "$SCHEME_WATCH" ]; then
	printf "\n\n Build watchOS ${APP} \n"
	set -o pipefail && xcodebuild -destination "${DEST_WATCH}" ${PROJECT} ${SCHEME_WATCH} clean build | xcpretty
fi



