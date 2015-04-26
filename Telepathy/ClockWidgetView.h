//
//  ClockWidgetView.h
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ClockWidgetView : NSView

@property (nonatomic, retain) NSImageView *profileImageView;
@property (nonatomic, retain) NSTextField *timeLabel;

@property (nonatomic, retain) NSTextField *weatherIconLabel;
@property (nonatomic, retain) NSTextField *cityLabel;

@property (nonatomic, retain) NSTextField *distanceLabel;

@end
