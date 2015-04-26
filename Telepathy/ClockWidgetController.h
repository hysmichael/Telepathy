//
//  ClockWidgetController.h
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClockWidgetView.h"

@interface ClockWidgetController : NSObject;

@property (nonatomic, retain) ClockWidgetView * view;

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView;

- (void) updateClockWidget;

@end
