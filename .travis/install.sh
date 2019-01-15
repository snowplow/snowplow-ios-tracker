#!/bin/sh

if [[ $PACKAGE_MANAGER == 'carthage' ]]; then
    :
elif [[ $PACKAGE_MANAGER == 'cocoapods' ]]; then
    pod repo update
    pod install
    pod update
fi
