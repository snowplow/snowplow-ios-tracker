Pod::Spec.new do |s|
    s.name             = "SnowplowTracker"
    s.version          = "5.6.0"
    s.summary          = "Snowplow event tracker for iOS, macOS, tvOS, watchOS for apps and games."
    s.description      = <<-DESC
    Snowplow is a mobile and event analytics platform with a difference: rather than tell our users how they should analyze their data, we deliver their event-level data in their own data warehouse, on their own Amazon Redshift or Postgres database, so they can analyze it any way they choose. Snowplow mobile is used by data-savvy games companies and app developers to better understand their users and how they engage with their games and applications. Snowplow is open source using the business-friendly Apache License, Version 2.0 and scales horizontally to many billions of events.
                         DESC
    s.homepage         = "http://snowplow.io"
    s.screenshots      = "https://d3i6fms1cm1j0i.cloudfront.net/github-wiki/images/snowplow-logo-large.png"
    s.license          = 'Apache License, Version 2.0'
    s.author           = { "Snowplow Analytics Ltd" => "support@snowplow.io" }
    s.source           = { :git => "https://github.com/snowplow/snowplow-ios-tracker.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/SnowPlowData'
    s.documentation_url	= 'https://github.com/snowplow/snowplow/wiki/iOS-Tracker'
  
    s.swift_version = '5.0'
    s.ios.deployment_target = '11.0'
    s.osx.deployment_target = '10.13'
    s.tvos.deployment_target = '12.0'
    s.watchos.deployment_target = '6.0'
  
    s.source_files = 'Sources/**/*.swift'
  
    s.ios.frameworks = 'CoreTelephony', 'UIKit', 'Foundation'
    s.osx.frameworks = 'AppKit', 'Foundation'
    s.tvos.frameworks = 'UIKit', 'Foundation'
  
    s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }
  
    s.dependency 'FMDB', '~> 2.7'
  end
