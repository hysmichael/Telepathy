//
//  DataManager.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "DataManager.h"

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
    if (self.userSelf && self.userPartner) {
        callback(STATUS_UserDataAllReady);
        return;
    }
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

- (BOOL)isPartnerActive {
    return [self.userPartner[@"isActive"] boolValue];
}

@end
