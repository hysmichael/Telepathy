//
//  EmotionChartView.h
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EmotionChartController;

@interface EmotionChartView : NSView

@property CGFloat daysInRange;

@property (weak) EmotionChartController *controller;
- (void) updateChartWithCurrent:(NSNumber *) current history:(NSArray *) history activeTokens:(NSArray *) tokens;

@end
