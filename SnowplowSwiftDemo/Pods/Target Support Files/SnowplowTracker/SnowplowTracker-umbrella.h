#ifdef __OBJC__
#import <UIKit/UIKit.h>
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
#import "SPEvent.h"
#import "SPSelfDescribingJson.h"

FOUNDATION_EXPORT double SnowplowTrackerVersionNumber;
FOUNDATION_EXPORT const unsigned char SnowplowTrackerVersionString[];

