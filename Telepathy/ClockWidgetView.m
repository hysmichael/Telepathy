//
//  ClockWidgetView.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "ClockWidgetView.h"

@implementation ClockWidgetView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.profileImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 80.0, 80.0)];
        [self.profileImageView setBoarderRadius:40.0 color:[NSColor grayColor] width:2.0];
        [self addSubview:self.profileImageView];
        
        self.timeLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(100.0, 45.0, 160.0, 23.0)] convertToTPLabel];
        [self.timeLabel setFont:[NSFont TPFontWithSize:18.0]];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
