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

+ (id) sharedManager;

- (void) prepareUserData: (void(^)(int)) callback;

- (NSDate *) convertDateFromSelfTimezoneToPartnerTimezone: (NSDate *) date;
- (void) getPartnerProfileImage: (void(^)(NSImage *)) callback;
- (BOOL) isPartnerActive;

- (CLLocation *) getPartnerLocation: (void(^)(CLPlacemark *)) callback;
- (void) updateSelfCurrentCoordinates:(CLLocationCoordinate2D) coordinate;
- (CLLocationDistance) distanceBetween;

@end
