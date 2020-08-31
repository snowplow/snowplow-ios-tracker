#ifdef __OBJC__
#import <Foundation/Foundation.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Snowplow.h"
#import "SPTracker.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPPayload.h"
#import "SPUtilities.h"
#import "SPRequestCallback.h"
#import "SPSelfDescribingJson.h"
#import "SPScreenState.h"
#import "SPDevicePlatform.h"
#import "SPEvent.h"
#import "SPEventBase.h"
#import "SPPageView.h"
#import "SPStructured.h"
#import "SPUnstructured.h"
#import "SPScreenView.h"
#import "SPConsentWithdrawn.h"
#import "SPConsentDocument.h"
#import "SPConsentGranted.h"
#import "SPTiming.h"
#import "SPEcommerce.h"
#import "SPEcommerceItem.h"
#import "SPPushNotification.h"
#import "SPForeground.h"
#import "SPBackground.h"
#import "SNOWError.h"
#import "SPSchemaRule.h"
#import "SPSchemaRuleset.h"
#import "SPGlobalContext.h"
#import "SPEventStore.h"
#import "SPSQLiteEventStore.h"
#import "SPNetworkConnection.h"
#import "SPDefaultNetworkConnection.h"
#import "SPRequest.h"
#import "SPRequestResult.h"
#import "SPEmitterEvent.h"

FOUNDATION_EXPORT double SnowplowTrackerVersionNumber;
FOUNDATION_EXPORT const unsigned char SnowplowTrackerVersionString[];

