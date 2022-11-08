Pod::Spec.new do |s|
  s.name             = "SnowplowTracker"
  s.version          = "4.0.1"
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
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.{m,h}'
  s.exclude_files = 'Sources/Snowplow/include/*.{m,h}'
  s.public_header_files = [
    'Sources/Core/**/SPSnowplow.h',
    'Sources/Core/**/SPTrackerConstants.h',
    'Sources/Core/**/SPLoggerDelegate.h',
    'Sources/Core/**/SPPayload.h',
    'Sources/Core/**/SPSelfDescribingJson.h',
    'Sources/Core/**/SPDevicePlatform.h',
    'Sources/Core/**/SPConfiguration.h',
    'Sources/Core/**/SPRemoteConfiguration.h',
    'Sources/Core/**/SPTrackerConfiguration.h',
    'Sources/Core/**/SPNetworkConfiguration.h',
    'Sources/Core/**/SPSubjectConfiguration.h',
    'Sources/Core/**/SPSessionConfiguration.h',
    'Sources/Core/**/SPEmitterConfiguration.h',
    'Sources/Core/**/SPGDPRConfiguration.h',
    'Sources/Core/**/SPGlobalContextsConfiguration.h',
    'Sources/Core/**/SPConfigurationBundle.h',
    'Sources/Core/**/SPTrackerController.h',
    'Sources/Core/**/SPSessionController.h',
    'Sources/Core/**/SPSubjectController.h',
    'Sources/Core/**/SPNetworkController.h',
    'Sources/Core/**/SPEmitterController.h',
    'Sources/Core/**/SPGDPRController.h',
    'Sources/Core/**/SPGlobalContextsController.h',
    'Sources/Core/**/SPNetworkConnection.h',
    'Sources/Core/**/SPDefaultNetworkConnection.h',
    'Sources/Core/**/SPEventStore.h',
    'Sources/Core/**/SPSQLiteEventStore.h',
    'Sources/Core/**/SPMemoryEventStore.h',
    'Sources/Core/**/SPRequest.h',
    'Sources/Core/**/SPRequestResult.h',
    'Sources/Core/**/SPEmitterEvent.h',
    'Sources/Core/**/SPRequestCallback.h',
    'Sources/Core/**/SPEventBase.h',
    'Sources/Core/**/SPPageView.h',
    'Sources/Core/**/SPStructured.h',
    'Sources/Core/**/SPSelfDescribing.h',
    'Sources/Core/**/SPScreenView.h',
    'Sources/Core/**/SPConsentWithdrawn.h',
    'Sources/Core/**/SPConsentDocument.h',
    'Sources/Core/**/SPConsentGranted.h',
    'Sources/Core/**/SPDeepLinkReceived.h',
    'Sources/Core/**/SPTiming.h',
    'Sources/Core/**/SPEcommerce.h',
    'Sources/Core/**/SPEcommerceItem.h',
    'Sources/Core/**/SPPushNotification.h',
    'Sources/Core/**/SPForeground.h',
    'Sources/Core/**/SPBackground.h',
    'Sources/Core/**/SNOWError.h',
    'Sources/Core/**/SPMessageNotification.h',
    'Sources/Core/**/SPMessageNotificationAttachment.h',
    'Sources/Core/**/SPDeepLinkEntity.h',
    'Sources/Core/**/SPLifecycleEntity.h',
    'Sources/Core/**/SPGlobalContext.h',
    'Sources/Core/**/SPSchemaRuleset.h',
    'Sources/Core/**/SPSchemaRule.h',
    'Sources/Core/**/SPTrackerStateSnapshot.h',
    'Sources/Core/**/SPState.h',
    'Sources/Core/**/SPSessionState.h',
    'Sources/Core/**/SPConfigurationState.h'
  ]

  s.osx.exclude_files = 'Sources/**/ScreenViewTracking/UIViewController+SPScreenView_SWIZZLE.*'
  s.tvos.exclude_files = 'Sources/**/ScreenViewTracking/UIViewController+SPScreenView_SWIZZLE.*'
  s.watchos.exclude_files = [
    'Sources/**/SNOWReachability.*',
    'Sources/**/UIViewController+SPScreenView_SWIZZLE.*'
  ]

  s.ios.frameworks = 'CoreTelephony', 'UIKit', 'Foundation'
  s.osx.frameworks = 'AppKit', 'Foundation'
  s.tvos.frameworks = 'UIKit', 'Foundation'

  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }

  s.dependency 'FMDB', '~> 2.7'
end

