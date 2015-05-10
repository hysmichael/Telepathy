//
//  AnniversaryController.m
//  Telepathy
//
//  Created by Michael Hong on 5/10/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "AnniversaryController.h"

@implementation AnniversaryController

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        self.view = [[AnniversaryView alloc] initWithFrame:frame];
        [parentView addSubview:self.view];
    }
    return self;
}

- (void)updateAnniversaryWidget {
    [[DataManager sharedManager] getAllAnniversaries:^(NSArray *objects) {
        NSUInteger count = [objects count];
        if (count == 0) {
            self.view.titleLable.stringValue = @"No anniversaries";
        } else {
            NSUInteger selected_index = arc4random_uniform((int)count);
            PFObject *anni = objects[selected_index];
            NSInteger days = [NSDate daysFromDate:anni[@"date"] toDate:[NSDate date]];
            NSString *title = anni[@"title"];
            if (days == 0) {
                self.view.titleLable.stringValue = [title stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                                  withString:[[title substringToIndex:1] uppercaseString]];
                self.view.daysLabel.stringValue = @"today";
            } else {
                self.view.titleLable.stringValue = [NSString stringWithFormat:(days > 0 ? @"Since %@" : @"To %@"), title];
                NSInteger days_abs = ABS(days);
                self.view.daysLabel.stringValue = [NSString stringWithFormat:(days_abs == 1 ? @"%ld day" : @"%ld days"), days_abs];
            }
        }
    }];
}

@end
