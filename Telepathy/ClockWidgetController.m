//
//  ClockWidgetController.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "ClockWidgetController.h"

#define dateFormatString1 @"HH:mm・MMM dd "
#define dateFormatString2 @"(E)"

@implementation ClockWidgetController

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        self.view = [[ClockWidgetView alloc] initWithFrame:frame];
        [parentView addSubview:self.view];
    }
    return self;
}

- (void) updateClockWidget {
    [self updatePartnerProfileImage];
    [self updateDatetimeComponent];
}

- (void) updateDatetimeComponent {
    NSDate *partnerTime = [[DataManager sharedManager] convertDateFromSelfTimezoneToPartnerTimezone:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatString1];
    NSString *rawDateStr1 = [dateFormatter stringFromDate:partnerTime];
    [dateFormatter setDateFormat:dateFormatString2];
    NSString *rawDateStr2 = [dateFormatter stringFromDate:partnerTime];
    
    NSMutableAttributedString *datetimeStr = [[NSMutableAttributedString alloc] init];
    NSAttributedString *attrDateStr1 = [[NSAttributedString alloc] initWithString:rawDateStr1 attributes:@{NSFontAttributeName: [NSFont TPFontWithSize:18.0]}];
    NSAttributedString *attrDateStr2 = [[NSAttributedString alloc] initWithString:rawDateStr2 attributes:@{NSFontAttributeName: [NSFont TPFontWithSize:12.0]}];
    [datetimeStr appendAttributedString:attrDateStr1];
    [datetimeStr appendAttributedString:attrDateStr2];
    
    [self.view.timeLabel setAttributedStringValue:datetimeStr];
}

- (void) updatePartnerProfileImage {
    [[DataManager sharedManager] getPartnerProfileImage:^(NSImage *image) {
        self.view.profileImageView.image = image;
    }];
    if ([[DataManager sharedManager] isPartnerActive]) {
        self.view.profileImageView.layer.borderColor = [TPColor green].CGColor;
    } else {
        self.view.profileImageView.layer.borderColor = [NSColor grayColor].CGColor;
    }
}

@end
