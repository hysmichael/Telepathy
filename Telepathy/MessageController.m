//
//  MessageController.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "MessageController.h"
#import "MessageBubbleView.h"

@implementation MessageController {
    NSMutableArray *messageData;
}

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        messageData = [[NSMutableArray alloc] init];
        self.view = [[BubbleScrollView alloc] initWithFrame:frame prototypeBubbleClass:[MessageBubbleView class] emptyMessage:@"No Messages"];
        [parentView addSubview:self.view];
    }
    return self;
}

- (void)updateMessageWidget {
    [[DataManager sharedManager] getAllMessages:^(NSArray *objs) {
        messageData = [objs mutableCopy];
        [self.view reloadAllBubbleViews:messageData];
        [[DataManager sharedManager] setAllMessagesAsRead];
    }];
}

@end
