# This podfile is intended for development and testing on Snowplow.
#
# If you are working on Snowplow, you do not need to have CocoaPods installed
# unless you want to install new development dependencies as the Pods directory
# is part of the source tree.

source 'https://github.com/CocoaPods/Specs.git'

target 'Snowplow-iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Snowplow-iOS
  inherit! :search_paths
  platform :ios, '8.4'
  pod 'FMDB'
  pod 'ReachabilitySwift'

  target 'Snowplow-iOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# target 'Snowplow-iOS-Static' do
#   # Comment the next line if you don't want to use dynamic frameworks
#   use_frameworks!
#
#   # Pods for Snowplow-iOS-Static
#
# end

# target 'Snowplow-macOS' do
#  # Comment the next line if you don't want to use dynamic frameworks
#   use_frameworks!
#
#  # Pods for Snowplow-macOS
#
#  target 'Snowplow-macOSTests' do
#    inherit! :search_paths
#    # Pods for testing
#  end
#
#end

#target 'Snowplow-watchOS' do
#  # Comment the next line if you don't want to use dynamic frameworks
#  use_frameworks!
#
#  # Pods for Snowplow-watchOS
#
#end
