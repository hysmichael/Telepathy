//
//  EmotionChartView.m
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EmotionChartView.h"

@implementation EmotionChartView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSBezierPath *baseLine = [[NSBezierPath alloc] init];
    [baseLine moveToPoint:NSMakePoint(5.0, 0.0)];
    [baseLine lineToPoint:NSMakePoint(255.0, 0.0)];
    [[TPColor chartBaseLineDarkBlue] setStroke];
    [baseLine stroke];
}

@end
