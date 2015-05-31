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
        NSMutableArray *displayedData = [NSMutableArray array];
        NSUInteger selected_index;
        if (count == 0) {
            [displayedData addObject:@{@"title":@"No anniversaries", @"days":@"-"}];
            selected_index = 0;
        } else {
            selected_index = arc4random_uniform((int)count);
            for (PFObject *anni in objects) {
                NSInteger days = [NSDate daysFromDate:anni[@"date"] toDate:[NSDate date]];
                NSString *title = anni[@"title"];
                NSString *titleStr, *daysStr;
                if (days == 0) {
                    titleStr = [title stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                              withString:[[title substringToIndex:1] uppercaseString]];
                    daysStr = @"today";
                } else {
                    titleStr = [NSString stringWithFormat:(days > 0 ? @"Since %@" : @"To %@"), title];
                    NSInteger days_abs = ABS(days);
                    daysStr = [NSString stringWithFormat:(days_abs == 1 ? @"%ld day" : @"%ld days"), days_abs];
                }
                [displayedData addObject:@{@"title": titleStr, @"days": daysStr}];
            }
        }
        [self.view setAnniversaryData:displayedData defaultIndex:selected_index];
    }];
}

@end
