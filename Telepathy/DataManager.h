//
//  DataManager.h
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#define STATUS_UserDataAllReady 0
#define STATUS_UserWithoutPartner 1
#define STATUS_OtherError 2

@protocol ActiveTokensNotificationDelegate <NSObject>
@required
- (void) didUpdateActiveTokens:(NSArray *) tokens;
@end

@interface DataManager : NSObject

@property PFUser *userSelf;
@property PFUser *userPartner;

@property BOOL hasNewNotification;
@property EKEventStore *eventStore;

@property NSMutableArray *activeTokens;
@property NSMutableSet *activeTokensNotificationDelegates;

@property BOOL onSpy;
@property BOOL onFocus;

+ (id) sharedManager;

- (void) prepareUserData: (void(^)(int)) callback;

// USER STATUS
- (void) checkNewNotification;
- (void) getPartnerActiveTokensSinceDays:(NSUInteger) numOfDays;
- (void) registerActiveTokensNotificationDelegate:(id<ActiveTokensNotificationDelegate>) delegate;

// USER IMAGE / TIMEZONE
- (NSDate *) convertDateFromSelfTimezoneToPartnerTimezone: (NSDate *) date;
- (void) getPartnerProfileImage: (void(^)(NSImage *)) callback;

// USER GEO LOCATION
- (CLLocation *) getPartnerLocation: (void(^)(CLPlacemark *)) callback;
- (BOOL) needsUpdateSelfCurrentLocation;
- (void) updateSelfCurrentLocation:(CLLocation *)location;
- (CLLocationDistance) distanceBetween;

// ANNIVERSARIES
- (void) getAllAnniversaries: (void(^)(NSArray *)) callback;
- (void) addAnniversary:(NSString *) name date:(NSDate *) date callback:(void(^)(BOOL)) callback;

// MESSAGES
- (void) getAllMessages: (void(^)(NSArray *)) callback;
- (void) getMessagesSinceDays:(NSUInteger) numOfDays callback:(void(^)(NSArray *)) callback;
- (void) sendMessage:(NSString *)messageText callback:(void(^)(BOOL)) callback;
- (BOOL) messageIsUnread:(PFObject *) message;
- (void) setAllMessagesAsRead;

// EVENTS
- (void) syncSelfCalenderEventsWithinDays:(NSUInteger) numOfDays;
- (void) getAllPartnerCalenderEvents:(void(^)(NSArray *)) callback;

// EMOTION INDEXES
- (void) getPartnerEIndexSinceDays:(NSUInteger) numOfDays callback:(void(^)(NSArray *)) callback;
- (void) setEIndex:(NSInteger) index callback:(void(^)(BOOL)) callback;

// COMMIT CHANGES
- (void) commitUserState;

@end
