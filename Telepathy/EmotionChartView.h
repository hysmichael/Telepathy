//
//  EmotionChartView.h
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSUInteger daysInRange = 7;

@interface EmotionChartView : NSView

- (void) updateChartWithCurrent:(NSNumber *) current andHistory:(NSArray *) history;

@end
