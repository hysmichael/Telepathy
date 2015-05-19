//
//  EventWidgetController.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EventWidgetController.h"
#import "EventBubbleView.h"

@implementation EventWidgetController {
    NSMutableArray *eventData;
}

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        eventData = [[NSMutableArray alloc] init];
        self.view = [[BubbleScrollView alloc] initWithFrame:frame prototypeBubbleClass:[EventBubbleView class] emptyMessage:@"No Events"];
        [parentView addSubview:self.view];
    }
    return self;
}

- (void)updateEventWidget {
    [[DataManager sharedManager] getAllPartnerCalenderEvents:^(NSArray *objs) {
        eventData = [objs mutableCopy];
        [self.view reloadAllBubbleViews:eventData];
    }];
    [[DataManager sharedManager] syncSelfCalenderEventsWithinDays:7];
}

@end

