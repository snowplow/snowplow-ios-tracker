Pod::Spec.new do |s|
  s.name             = "SnowplowTracker"
  s.version          = "0.6.1"
  s.summary          = "Snowplow event tracker for iOS 7+. Add analytics to your iOS apps and games."
  s.description      = <<-DESC
  Snowplow is a mobile and event analytics platform with a difference: rather than tell our users how they should analyze their data, we deliver their event-level data in their own data warehouse, on their own Amazon Redshift or Postgres database, so they can analyze it any way they choose. Snowplow mobile is used by data-savvy games companies and app developers to better understand their users and how they engage with their games and applications. Snowplow is open source using the business-friendly Apache License, Version 2.0 and scales horizontally to many billions of events.
                       DESC
  s.homepage         = "http://snowplowanalytics.com"
  s.screenshots      = "https://d3i6fms1cm1j0i.cloudfront.net/github-wiki/images/snowplow-logo-large.png"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Snowplow Analytics Ltd" => "support@snowplowanalytics.com" }
  s.source           = { :git => "https://github.com/snowplow/snowplow-objc-tracker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/SnowPlowData'
  s.documentation_url	= 'https://github.com/snowplow/snowplow/wiki/iOS-Tracker'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.source_files = 'Snowplow/*.{m,h}'
  s.public_header_files = [
    'Snowplow/Snowplow.h', 
    'Snowplow/SPTracker.h', 
    'Snowplow/SPEmitter.h', 
    'Snowplow/SPSubject.h', 
    'Snowplow/SPPayload.h', 
    'Snowplow/SPUtilities.h', 
    'Snowplow/SPRequestCallback.h', 
    'Snowplow/SPEvent.h', 
    'Snowplow/SPSelfDescribingJson.h'
  ]

  s.ios.frameworks = 'CoreTelephony', 'UIKit', 'Foundation'
  s.osx.frameworks = 'AppKit', 'Foundation'
  s.tvos.frameworks = 'UIKit', 'Foundation'
  s.dependency 'FMDB', '2.5'
  s.ios.dependency 'Reachability', '3.2'
end
