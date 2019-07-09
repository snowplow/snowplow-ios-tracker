# This podfile is intended for development and testing on Snowplow.
#
# If you are working on Snowplow, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.

source 'https://github.com/CocoaPods/Specs.git'
target 'Snowplow-iOS' do
    inherit! :search_paths
    platform :ios, '8.4'
    pod 'FMDB'
    pod 'Reachability'
end

target 'Snowplow-macOS' do
    pod 'FMDB'
    platform :osx, '10.9'
end

# FIXME: Is this needed? 
# target 'Snowplow-iOSTests' do
#     inherit! :search_paths
#     platform :ios, '8.4'
#     pod 'Nocilla'
#     pod 'SnowplowIgluClient', :git => 'https://github.com/snowplow/iglu-objc-client.git', :branch => 'feature/carthage'
# end

# target 'Snowplow-macOSTests' do
#     platform :osx, '10.9'
#     pod 'Nocilla'
#     pod 'SnowplowIgluClient', :git => 'https://github.com/snowplow/iglu-objc-client.git', :branch => 'feature/carthage'
# end
