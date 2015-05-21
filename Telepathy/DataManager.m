//
//  DataManager.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "DataManager.h"
#import <CoreLocation/CoreLocation.h>

#define NULL_OBJ [NSNull null]
#define MINUTE 60

@implementation DataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:nil];
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
            [self setActiveStatus:true callback:nil];
            callback(STATUS_UserDataAllReady);
        } else {
            callback(STATUS_OtherError);
        }
    }];
}

- (void)setActiveStatus:(BOOL)isActive callback:(void (^)(BOOL))callback {    
    // avoid multiple firing
    if ([self.userSelf[@"isActive"] boolValue] == isActive) {
        if (callback) callback(true);
        return;
    };
    
    NSMutableArray *updateQueue = [[NSMutableArray alloc] initWithObjects:self.userSelf, nil];
    self.userSelf[@"isActive"] = [NSNumber numberWithBool:isActive];
    if (isActive) {
        // setup a new active session
        self.activeSession = [PFObject objectWithClassName:@"UserActiveSession"];
        self.activeSession[@"user"]      = self.userSelf;
        self.activeSession[@"startTime"] = [NSDate date];
        [updateQueue addObject:self.activeSession];
    } else if (self.activeSession) {
        // close up the current active session
        NSDate *endTime = [NSDate date];
        self.activeSession[@"endTime"]  = endTime;
        self.activeSession[@"duration"] = @([endTime timeIntervalSinceDate:self.activeSession[@"startTime"]]);
        [updateQueue addObject:self.activeSession];
    }
    [PFObject saveAllInBackground:updateQueue block:^(BOOL succeeded, NSError *error){
        if (callback) callback(succeeded);
        if (!isActive) self.activeSession = nil;
    }];
}

- (NSDate *)convertDateFromSelfTimezoneToPartnerTimezone:(NSDate *)date {
    NSNumber *selfTimezone = self.userSelf[@"timezone"];
    NSNumber *partnerTimezone = self.userPartner[@"timezone"];
    int timeInterval = (partnerTimezone.intValue - selfTimezone.intValue) * 3600;
    return [date dateByAddingTimeInterval:timeInterval];
}

- (NSDate *)convertDateFromPartnerTimezoneToSelfTimezone:(NSDate *)date {
    NSNumber *selfTimezone = self.userSelf[@"timezone"];
    NSNumber *partnerTimezone = self.userPartner[@"timezone"];
    int timeInterval = (selfTimezone.intValue - partnerTimezone.intValue) * 3600;
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

- (BOOL)isPartnerActive {
    return [self.userPartner[@"isActive"] boolValue];
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
    NSDate *lastupdate = self.userSelf[@"geoTimestamp"];
    if (!lastupdate) return true;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastupdate];
    return (interval > 3600);
}

- (void) updateSelfCurrentLocation:(CLLocation *)location {
    CLLocationCoordinate2D coordinate = location.coordinate;
    self.userSelf[@"latitude"] = @(coordinate.latitude);
    self.userSelf[@"longitude"] = @(coordinate.longitude);
    self.userSelf[@"geoTimestamp"] = location.timestamp;
}

- (CLLocationDistance)distanceBetween {
    CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:[self.userSelf[@"latitude"] doubleValue] longitude:[self.userSelf[@"longitude"] floatValue]];
    CLLocation *partnerLocation = [[CLLocation alloc] initWithLatitude:[self.userPartner[@"latitude"] doubleValue] longitude:[self.userPartner[@"longitude"] floatValue]];
    return [selfLocation distanceFromLocation:partnerLocation];
}

- (void)getAllAnniversaries:(void (^)(NSArray *))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"Anniversary"];
    [query whereKey:@"userId" containedIn:@[self.userSelf.objectId, self.userPartner.objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        }
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

- (void)sendMessage:(NSString *)messageText callback:(void (^)(BOOL))callback {
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"userId"] = self.userSelf.objectId;
    message[@"postAt"] = [NSDate date];
    message[@"text"]   = messageText;
    [message saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        callback(succeeded);
    }];
}

- (BOOL)messageIsUnread:(PFObject *)message {
    NSDate *lastRead = self.userSelf[@"messageTimestamp"];
    if (!lastRead) return true;
    NSTimeInterval interval = [message[@"postAt"] timeIntervalSinceDate:lastRead];
    return (interval > 0);
}

- (void)setAllMessagesAsRead {
    self.userSelf[@"messageTimestamp"] = [NSDate date];
}

- (void) syncSelfCalenderEventsWithinDays:(NSUInteger)numOfDays {
    if ([EKEventStore authorizationStatusForEntityType:EKEntityMaskEvent] == EKAuthorizationStatusAuthorized) {
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
    PFObject *indexObj = [PFObject objectWithClassName:@"EIndex"];
    indexObj[@"userId"] = self.userSelf.objectId;
    indexObj[@"postAt"] = [NSDate date];
    indexObj[@"oldValue"] = self.userSelf[@"currentEIndex"];
    indexObj[@"newValue"] = @(index);
    self.userSelf[@"currentEIndex"] = @(index);
    [PFObject saveAllInBackground:@[indexObj, self.userSelf] block:^(BOOL succeeded, NSError *error) {
        callback(succeeded);
    }];
}

- (void)commitUserState {
    [self.userSelf saveInBackground];
}

@end
