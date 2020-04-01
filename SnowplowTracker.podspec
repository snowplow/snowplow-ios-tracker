Pod::Spec.new do |s|
  s.name             = "SnowplowTracker"
  s.version          = "1.2.2"
  s.summary          = "Snowplow event tracker for iOS, macOS, tvOS, watchOS for apps and games."
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

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.requires_arc = true

  s.ios.source_files = 'Snowplow/*.swift'
  s.osx.exclude_files = 'Snowplow/UIViewController+SPScreenView_SWIZZLE.*'
  s.tvos.exclude_files = 'Snowplow/UIViewController+SPScreenView_SWIZZLE.*'
  s.watchos.exclude_files = [
    'Snowplow/UIViewController+SPScreenView_SWIZZLE.*',
    'Snowplow/SNOWReachability.*'
  ]

  s.source_files = 'Snowplow/*.{m,h}', 'Snowplow/Events/*.{m,h}', 'Snowplow/GlobalContext/*.{m,h}'
  s.public_header_files = [
    'Snowplow/Snowplow.h', 
    'Snowplow/SPTracker.h', 
    'Snowplow/SPEmitter.h', 
    'Snowplow/SPSubject.h', 
    'Snowplow/SPPayload.h', 
    'Snowplow/SPUtilities.h', 
    'Snowplow/SPRequestCallback.h', 
    'Snowplow/SPRequestResponse.h',
    'Snowplow/SPSelfDescribingJson.h',
    'Snowplow/SPScreenState.h',
    'Snowplow/SPDevicePlatform.h',
    'Snowplow/Events/SPEvent.h',
    'Snowplow/Events/SPEventBase.h',
    'Snowplow/Events/SPPageView.h',
    'Snowplow/Events/SPStructured.h',
    'Snowplow/Events/SPUnstructured.h',
    'Snowplow/Events/SPScreenView.h',
    'Snowplow/Events/SPConsentWithdrawn.h',
    'Snowplow/Events/SPConsentGranted.h',
    'Snowplow/Events/SPTiming.h',
    'Snowplow/Events/SPEcommerce.h',
    'Snowplow/Events/SPEcommerceItem.h',
    'Snowplow/Events/SPPushNotification.h',
    'Snowplow/Events/SPForeground.h',
    'Snowplow/Events/SPBackground.h',
    'Snowplow/Events/SNOWError.h',
    'Snowplow/GlobalContext/SPSchemaRule.h',
    'Snowplow/GlobalContext/SPSchemaRuleset.h',
    'Snowplow/GlobalContext/SPGlobalContext.h'
  ]

  s.ios.frameworks = 'CoreTelephony', 'UIKit', 'Foundation'
  s.osx.frameworks = 'AppKit', 'Foundation'
  s.tvos.frameworks = 'UIKit', 'Foundation'

  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }

  s.dependency 'FMDB', '~> 2.6'
end

