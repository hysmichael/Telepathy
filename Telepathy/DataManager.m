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

@implementation DataManager

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
    if ([self.userSelf[@"isActive"] boolValue] == isActive) return;
    
    NSMutableArray *updateQueue = [[NSMutableArray alloc] initWithObjects:self.userSelf, nil];
    self.userSelf[@"isActive"] = @(isActive);
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
    [PFObject saveAllInBackground:updateQueue block: ^(BOOL succeeded, NSError *error){
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
    [self.userSelf saveInBackground];
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

@end
