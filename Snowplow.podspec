Pod::Spec.new do |s|
  s.name             = "Snowplow"
  s.version          = "0.1.0" # Change to File.read('VERSION')
  s.summary          = "Snowplow event tracker for iOS 6+. Add analytics to your iOS apps and games."
  s.description      = <<-DESC
                       An optional longer description of Snowplow

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://snowplowanalytics.com"
  s.screenshots      = "https://d3i6fms1cm1j0i.cloudfront.net/github-wiki/images/snowplow-logo-large.png"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Jonathan Almeida" => "jonathan@snowplowanalytics.com" }
  s.source           = { :git => "https://github.com/snowplow/snowplow-ios-tracker.git", :tag => "v0.1" }
  s.social_media_url = 'https://twitter.com/SnowPlowData'

  s.platform     = :ios, '7.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'Snowplow/*.{m,h}'
  # s.resources = 'Assets/*.png'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Snowplow/*.h'
  s.frameworks = 'CoreTelephony', 'UIKit', 'Foundation'
  s.dependency 'AFNetworking', '~> 2.0'
end
