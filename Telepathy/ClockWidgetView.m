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
        
        self.timeLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(93.0, 48.0, 168.0, 20.0)] convertToTPLabel];
        [self.timeLabel setTextColor:[TPColor defaultBlack]];
        [self addSubview:self.timeLabel];
        
        self.weatherIconLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(90.0, 10.0, 25.0, 28.0)] convertToTPLabel];
        [self.weatherIconLabel setFont:[NSFont fontWithName:@"Climacons-Font" size:25.0]];
        [self.weatherIconLabel setAlignment:NSCenterTextAlignment];
        [self addSubview:self.weatherIconLabel];
        
        self.cityLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(118.0, 20.0, 134.0, 20.0)] convertToTPLabel];
        [self.cityLabel setFont:[NSFont TPFontWithSize:16.0]];
        [self.cityLabel setTextColor:[TPColor defaultBlack]];
        [self addSubview:self.cityLabel];
        
        self.distanceLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(119.0, 10.0, 100.0, 10.0)] convertToTPLabel];
        [self.distanceLabel setFont:[NSFont TPFontWithSize:10.0]];
        [self.distanceLabel setTextColor:[TPColor defaultBlack]];
        [self addSubview:self.distanceLabel];
        self.distanceLabel.stringValue = @"- km";
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
