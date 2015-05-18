//
//  EventBubbleView.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EventBubbleView.h"

@implementation EventBubbleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[TPColor lightBlue:50.0]];
        [self setBoarderRadius:10.0 color:[TPColor mediumBlue] width:2.0];
    }
    return self;
}

- (CGFloat)setContentObject:(id)object {
    return 30.0;
}

@end
