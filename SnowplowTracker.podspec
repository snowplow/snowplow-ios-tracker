Pod::Spec.new do |s|
  s.name             = "SnowplowTracker"
  s.version          = "4.0.1"
  s.summary          = "Snowplow event tracker for iOS, macOS, tvOS, watchOS for apps and games."
  s.description      = <<-DESC
  Snowplow is a mobile and event analytics platform with a difference: rather than tell our users how they should analyze their data, we deliver their event-level data in their own data warehouse, on their own Amazon Redshift or Postgres database, so they can analyze it any way they choose. Snowplow mobile is used by data-savvy games companies and app developers to better understand their users and how they engage with their games and applications. Snowplow is open source using the business-friendly Apache License, Version 2.0 and scales horizontally to many billions of events.
                       DESC
  s.homepage         = "http://snowplow.io"
  s.screenshots      = "https://d3i6fms1cm1j0i.cloudfront.net/github-wiki/images/snowplow-logo-large.png"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Snowplow Analytics Ltd" => "support@snowplow.io" }
  s.source           = { :git => "https://github.com/snowplow/snowplow-objc-tracker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/SnowPlowData'
  s.documentation_url	= 'https://github.com/snowplow/snowplow/wiki/iOS-Tracker'

  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.requires_arc = true

  s.source_files = 'Snowplow/**/*.{m,h}'
  s.exclude_files = 'Snowplow/include/*.{m,h}'
  s.public_header_files = [
    'Snowplow/Internal/**/SPSnowplow.h',
    'Snowplow/Internal/**/SPTrackerConstants.h',
    'Snowplow/Internal/**/SPLoggerDelegate.h',
    'Snowplow/Internal/**/SPPayload.h',
    'Snowplow/Internal/**/SPSelfDescribingJson.h',
    'Snowplow/Internal/**/SPDevicePlatform.h',
    'Snowplow/Internal/**/SPConfiguration.h',
    'Snowplow/Internal/**/SPRemoteConfiguration.h',
    'Snowplow/Internal/**/SPTrackerConfiguration.h',
    'Snowplow/Internal/**/SPNetworkConfiguration.h',
    'Snowplow/Internal/**/SPSubjectConfiguration.h',
    'Snowplow/Internal/**/SPSessionConfiguration.h',
    'Snowplow/Internal/**/SPEmitterConfiguration.h',
    'Snowplow/Internal/**/SPGDPRConfiguration.h',
    'Snowplow/Internal/**/SPGlobalContextsConfiguration.h',
    'Snowplow/Internal/**/SPConfigurationBundle.h',
    'Snowplow/Internal/**/SPTrackerController.h',
    'Snowplow/Internal/**/SPSessionController.h',
    'Snowplow/Internal/**/SPSubjectController.h',
    'Snowplow/Internal/**/SPNetworkController.h',
    'Snowplow/Internal/**/SPEmitterController.h',
    'Snowplow/Internal/**/SPGDPRController.h',
    'Snowplow/Internal/**/SPGlobalContextsController.h',
    'Snowplow/Internal/**/SPNetworkConnection.h',
    'Snowplow/Internal/**/SPDefaultNetworkConnection.h',
    'Snowplow/Internal/**/SPEventStore.h',
    'Snowplow/Internal/**/SPSQLiteEventStore.h',
    'Snowplow/Internal/**/SPMemoryEventStore.h',
    'Snowplow/Internal/**/SPRequest.h',
    'Snowplow/Internal/**/SPRequestResult.h',
    'Snowplow/Internal/**/SPEmitterEvent.h',
    'Snowplow/Internal/**/SPRequestCallback.h',
    'Snowplow/Internal/**/SPEventBase.h',
    'Snowplow/Internal/**/SPPageView.h',
    'Snowplow/Internal/**/SPStructured.h',
    'Snowplow/Internal/**/SPSelfDescribing.h',
    'Snowplow/Internal/**/SPScreenView.h',
    'Snowplow/Internal/**/SPConsentWithdrawn.h',
    'Snowplow/Internal/**/SPConsentDocument.h',
    'Snowplow/Internal/**/SPConsentGranted.h',
    'Snowplow/Internal/**/SPDeepLinkReceived.h',
    'Snowplow/Internal/**/SPTiming.h',
    'Snowplow/Internal/**/SPEcommerce.h',
    'Snowplow/Internal/**/SPEcommerceItem.h',
    'Snowplow/Internal/**/SPPushNotification.h',
    'Snowplow/Internal/**/SPForeground.h',
    'Snowplow/Internal/**/SPBackground.h',
    'Snowplow/Internal/**/SNOWError.h',
    'Snowplow/Internal/**/SPMessageNotification.h',
    'Snowplow/Internal/**/SPMessageNotificationAttachment.h',
    'Snowplow/Internal/**/SPDeepLinkEntity.h',
    'Snowplow/Internal/**/SPLifecycleEntity.h',
    'Snowplow/Internal/**/SPGlobalContext.h',
    'Snowplow/Internal/**/SPSchemaRuleset.h',
    'Snowplow/Internal/**/SPSchemaRule.h',
    'Snowplow/Internal/**/SPTrackerStateSnapshot.h',
    'Snowplow/Internal/**/SPState.h',
    'Snowplow/Internal/**/SPSessionState.h',
    'Snowplow/Internal/**/SPConfigurationState.h'
  ]

  s.osx.exclude_files = 'Snowplow/**/ScreenViewTracking/UIViewController+SPScreenView_SWIZZLE.*'
  s.tvos.exclude_files = 'Snowplow/**/ScreenViewTracking/UIViewController+SPScreenView_SWIZZLE.*'
  s.watchos.exclude_files = [
    'Snowplow/**/SNOWReachability.*',
    'Snowplow/**/UIViewController+SPScreenView_SWIZZLE.*'
  ]

  s.ios.frameworks = 'CoreTelephony', 'UIKit', 'Foundation'
  s.osx.frameworks = 'AppKit', 'Foundation'
  s.tvos.frameworks = 'UIKit', 'Foundation'

  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }

  s.dependency 'FMDB', '~> 2.7'
end

