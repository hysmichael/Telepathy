//
//  DataManager.h
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATUS_UserDataAllReady 0
#define STATUS_UserWithoutPartner 1
#define STATUS_OtherError 2

@interface DataManager : NSObject

@property PFUser *userSelf;
@property PFUser *userPartner;

@property PFObject *activeSession;

+ (id) sharedManager;

- (void) prepareUserData: (void(^)(int)) callback;

// USER STATUS
- (void) setActiveStatus:(BOOL)isActive callback:(void(^)(BOOL)) callback;
- (BOOL) isPartnerActive;

// USER IMAGE / TIMEZONE
- (NSDate *) convertDateFromSelfTimezoneToPartnerTimezone: (NSDate *) date;
- (NSDate *) convertDateFromPartnerTimezoneToSelfTimezone: (NSDate *) date;
- (void) getPartnerProfileImage: (void(^)(NSImage *)) callback;

// USER GEO LOCATION
- (CLLocation *) getPartnerLocation: (void(^)(CLPlacemark *)) callback;
- (BOOL) needsUpdateSelfCurrentLocation;
- (void) updateSelfCurrentLocation:(CLLocation *)location;
- (CLLocationDistance) distanceBetween;

// ANNIVERSARIES
- (void) getAllAnniversaries: (void(^)(NSArray *)) callback;

// MESSAGES
- (void) getAllMessages: (void(^)(NSArray *)) callback;

@end
