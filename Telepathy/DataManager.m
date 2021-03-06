//
//  DataManager.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

#define NULL_OBJ [NSNull null]
#define MINUTE 60

#define UNAVAILABLE_ON_SPY if (self.onSpy) return;

@implementation DataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {}];
        self.activeTokensNotificationDelegates = [[NSMutableSet alloc] init];
    }
    return self;
}

+ (id)sharedManager {
    static DataManager *sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}

- (void)prepareUserData:(void (^)(int))callback {
    self.userSelf = [PFUser currentUser];
    NSString *partnerID = self.userSelf[@"partnerId"];
    if ([partnerID isEqualTo:NULL_OBJ]) {
        callback(STATUS_UserWithoutPartner);
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:partnerID block:^(PFObject *object, NSError *error) {
        if (object) {
            self.userPartner = (PFUser *)object;
            if (self.onSpy) {
                /* onSpy mode: switch users */
                PFUser *tmp = self.userSelf;
                self.userSelf = self.userPartner;
                self.userPartner = tmp;
                
                /* clean cache */
                self.activeTokens = nil;
            }
            callback(STATUS_UserDataAllReady);
        } else {
            callback(STATUS_OtherError);
        }
    }];
}

- (NSDate *)convertDateFromSelfTimezoneToPartnerTimezone:(NSDate *)date {
    NSNumber *selfTimezone = self.userSelf[@"timezone"];
    NSNumber *partnerTimezone = self.userPartner[@"timezone"];
    int timeInterval = (partnerTimezone.intValue - selfTimezone.intValue) * 3600;
    return [date dateByAddingTimeInterval:timeInterval];
}

- (void)getPartnerProfileImage:(void (^)(NSImage *))callback {
    PFFile *userImageFile = self.userPartner[@"image"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            NSImage *image = [[NSImage alloc] initWithData:imageData];
            callback(image);
        }
    }];
}

- (NSString *)getPartnerPronoun {
    return ([self.userPartner[@"gender"] isEqualToString:@"male"] ? @"Him" : @"Her");
}

- (void)checkNewNotification {
    UNAVAILABLE_ON_SPY
    NSDate *notificationTimestamp = self.userSelf[@"notificationTimestamp"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"userId" equalTo:self.userPartner.objectId];
    if (notificationTimestamp) [query whereKey:@"postAt" greaterThan:notificationTimestamp];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSUInteger count = [objects count];
            if (count > 0) {
                self.hasNewNotification = true;
                AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                [delegate refreshStatusItemView];
            }
            if (count < 3) {
                for (PFObject *message in objects) {
                    NSUserNotification *notification = [[NSUserNotification alloc] init];
                    notification.title = [NSString stringWithFormat:@"New Message from %@", [self getPartnerPronoun]];
                    notification.informativeText = message[@"text"];
                    notification.soundName = NSUserNotificationDefaultSoundName;
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                }
            } else {
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = [NSString stringWithFormat:@"%lu New Messages from %@", count, [self getPartnerPronoun]];
                notification.soundName = NSUserNotificationDefaultSoundName;
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
        }
    }];
    
    PFObject *token = [PFObject objectWithClassName:@"ActiveToken"];
    token[@"userId"] = self.userSelf.objectId;
    token[@"type"] = @"Background";
    self.userSelf[@"notificationTimestamp"] = [NSDate date];
    [token saveInBackground];
    [self.userSelf saveInBackground];
}

- (void)getPartnerActiveTokensSinceDays:(NSUInteger)numOfDays {
    PFQuery *query = [PFQuery queryWithClassName:@"ActiveToken"];
    [query whereKey:@"userId" equalTo:self.userPartner.objectId];
    if (self.activeTokens && [self.activeTokens count] > 0) {
        PFObject *lastToken = [self.activeTokens lastObject];
        [query whereKey:@"createdAt" greaterThan:lastToken.createdAt];
    } else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = -numOfDays;
        NSDate *startDate = [calendar dateByAddingComponents:dateComponents
                                                      toDate:[NSDate date]
                                                     options:0];
        [query whereKey:@"createdAt" greaterThan:startDate];
    }
    [query orderByAscending:@"createdAt"];
    [query setLimit:560];   /* 20 Hours a day all active */
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (!self.activeTokens) self.activeTokens = [[NSMutableArray alloc] init];
            [self.activeTokens addObjectsFromArray:objects];
            for (id<ActiveTokensNotificationDelegate> delegate in self.activeTokensNotificationDelegates) {
                [delegate didUpdateActiveTokens:self.activeTokens];
            }
        }
    }];
}

- (void)registerActiveTokensNotificationDelegate:(id<ActiveTokensNotificationDelegate>)delegate {
    [self.activeTokensNotificationDelegates addObject:delegate];
}

- (CLLocation *)getPartnerLocation:(void (^)(CLPlacemark *))callback {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.userPartner[@"latitude"] doubleValue] longitude:[self.userPartner[@"longitude"] floatValue]];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            callback(placemark);
        }
    }];
    return location;
}

- (BOOL)needsUpdateSelfCurrentLocation {
    if (self.onSpy) return false;
    NSDate *lastupdate = self.userSelf[@"geoTimestamp"];
    if (!lastupdate) return true;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastupdate];
    return (interval > 3600);
}

- (void) updateSelfCurrentLocation:(CLLocation *)location {
    UNAVAILABLE_ON_SPY
    CLLocationCoordinate2D coordinate = location.coordinate;
    self.userSelf[@"latitude"] = @(coordinate.latitude);
    self.userSelf[@"longitude"] = @(coordinate.longitude);
    self.userSelf[@"geoTimestamp"] = location.timestamp;
    self.userSelf[@"timezone"] = @([[NSTimeZone localTimeZone] secondsFromGMT] / 3600);
}

- (CLLocationDistance)distanceBetween {
    CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:[self.userSelf[@"latitude"] doubleValue] longitude:[self.userSelf[@"longitude"] floatValue]];
    CLLocation *partnerLocation = [[CLLocation alloc] initWithLatitude:[self.userPartner[@"latitude"] doubleValue] longitude:[self.userPartner[@"longitude"] floatValue]];
    return [selfLocation distanceFromLocation:partnerLocation];
}

- (void)getAllAnniversaries:(void (^)(NSArray *))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"Anniversary"];
    [query whereKey:@"userId" containedIn:@[self.userSelf.objectId, self.userPartner.objectId]];
    [query orderByAscending:@"date"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        }
    }];
}

- (void)addAnniversary:(NSString *)name date:(NSDate *)date callback:(void (^)(BOOL))callback {
    PFObject *anniversary = [PFObject objectWithClassName:@"Anniversary"];
    anniversary[@"userId"]  = self.userSelf.objectId;
    anniversary[@"date"]    = date;
    anniversary[@"title"]   = name;
    [anniversary saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (callback) callback(succeeded);
    }];
}

- (void)getAllMessages:(void (^)(NSArray *))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"userId" equalTo:self.userPartner.objectId];
    [query orderByDescending:@"postAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        }
    }];
}

- (void)getMessagesSinceDays:(NSUInteger)numOfDays callback:(void (^)(NSArray *))callback {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = -numOfDays;
    NSDate *startDate = [calendar dateByAddingComponents:dateComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"userId" equalTo:self.userPartner.objectId];
    [query whereKey:@"postAt" greaterThanOrEqualTo:startDate];
    [query orderByDescending:@"postAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        }
    }];
}

- (void)sendMessage:(NSString *)messageText callback:(void (^)(BOOL))callback {
    UNAVAILABLE_ON_SPY
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"userId"] = self.userSelf.objectId;
    message[@"postAt"] = [NSDate date];
    message[@"text"]   = messageText;
    [message saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (callback) callback(succeeded);
    }];
}

- (BOOL)messageIsUnread:(PFObject *)message {
    NSDate *lastRead = self.userSelf[@"messageTimestamp"];
    if (!lastRead) return true;
    NSTimeInterval interval = [message[@"postAt"] timeIntervalSinceDate:lastRead];
    return (interval > 0);
}

- (void)setAllMessagesAsRead {
    UNAVAILABLE_ON_SPY
    self.userSelf[@"messageTimestamp"] = [NSDate date];
}

- (void) __syncSelfCalenderEventsWithinDays:(NSUInteger)numOfDays {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *startDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = numOfDays;
    NSDate *endDate = [calendar dateByAddingComponents:dateComponents
                                                toDate:startDate
                                               options:0];
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:nil];
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    
    PFQuery *query = [PFQuery queryWithClassName:@"CalenderEvent"];
    [query whereKey:@"userId" equalTo:self.userSelf.objectId];
    [query whereKey:@"endDate" greaterThanOrEqualTo:startDate];
    [query whereKey:@"startDate" lessThanOrEqualTo:endDate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableSet *eventsOnServer = [[NSMutableSet alloc] init];
            for (PFObject *object in objects) [eventsOnServer addObject:object[@"eventId"]];
            NSMutableArray *eventObjects = [[NSMutableArray alloc] init];
            for (EKEvent *event in events) {
                if (![eventsOnServer containsObject:event.eventIdentifier]) {
                    PFObject *eventObject = [PFObject objectWithClassName:@"CalenderEvent"];
                    eventObject[@"eventId"]     = event.eventIdentifier;
                    eventObject[@"startDate"]   = event.startDate;
                    eventObject[@"endDate"]     = event.endDate;
                    eventObject[@"allDay"]      = @(event.allDay);
                    eventObject[@"userId"]      = self.userSelf.objectId;
                    if (event.title)    eventObject[@"title"]    = event.title;
                    if (event.location) eventObject[@"location"] = event.location;
                    [eventObjects addObject:eventObject];
                }
            }
            [PFObject saveAllInBackground:eventObjects];
        }
    }];
}

- (void) syncSelfCalenderEventsWithinDays:(NSUInteger)numOfDays {
    UNAVAILABLE_ON_SPY
    if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        [self __syncSelfCalenderEventsWithinDays:numOfDays];
    } else {
        /* reissue the permission request */
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self __syncSelfCalenderEventsWithinDays:numOfDays];
            }
        }];
    }
}

- (void)getAllPartnerCalenderEvents:(void (^)(NSArray *))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"CalenderEvent"];
    [query whereKey:@"userId" equalTo:self.userPartner.objectId];
    [query whereKey:@"endDate" greaterThanOrEqualTo:[NSDate date]];
    [query orderByAscending:@"startDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        }
    }];
}

- (void)getPartnerEIndexSinceDays:(NSUInteger)numOfDays callback:(void (^)(NSArray *))callback {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = -numOfDays;
    NSDate *startDate = [calendar dateByAddingComponents:dateComponents
                                                toDate:[NSDate date]
                                               options:0];
    
    PFQuery *query = [PFQuery queryWithClassName:@"EIndex"];
    [query whereKey:@"userId" equalTo:self.userPartner.objectId];
    [query whereKey:@"postAt" greaterThanOrEqualTo:startDate];
    [query orderByAscending:@"postAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        }
    }];
}

- (void)setEIndex:(NSInteger)index callback:(void (^)(BOOL))callback {
    UNAVAILABLE_ON_SPY
    PFObject *indexObj = [PFObject objectWithClassName:@"EIndex"];
    indexObj[@"userId"] = self.userSelf.objectId;
    indexObj[@"postAt"] = [NSDate date];
    indexObj[@"oldValue"] = self.userSelf[@"currentEIndex"];
    indexObj[@"newValue"] = @(index);
    self.userSelf[@"currentEIndex"] = @(index);
    [PFObject saveAllInBackground:@[indexObj, self.userSelf] block:^(BOOL succeeded, NSError *error) {
        if (callback) callback(succeeded);
    }];
}


/* commit user state when panel is closed */
- (void)commitUserState {
    /* check if user has logged in */
//    if (!self.userSelf) return;
    
    /* during spy mode, when panel is closed, the spy session is terminated
       do not commit user state in replacement of partner */
    if (self.onSpy) {
        [self setOnSpy:false];
        self.activeTokens = nil;
        return;
    }
    
    /* commit a user active token */
    /* (no commitment if the previous token is within 15 minutes) */
    NSDate *notificationTimestamp = self.userSelf[@"notificationTimestamp"];
    if (!notificationTimestamp || [[NSDate date] timeIntervalSinceDate:notificationTimestamp] > 900) {
        PFObject *token = [PFObject objectWithClassName:@"ActiveToken"];
        token[@"userId"] = self.userSelf.objectId;
        token[@"type"] = @"Active";
        [token saveInBackground];
    }
    self.userSelf[@"notificationTimestamp"] = [NSDate date];
        
    /* set new notification as false */
    self.hasNewNotification = false;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate refreshStatusItemView];
    
    [self.userSelf saveInBackground];
}

@end
