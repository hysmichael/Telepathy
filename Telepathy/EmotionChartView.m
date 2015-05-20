//
//  EmotionChartView.m
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EmotionChartView.h"
#import "DateFormats.h"

@interface EmotionChartView()

@property NSMutableArray *keyPoints;
@property NSMutableArray *keyValues;

@property NSView *activeIndicator;
@property NSTextField *timeLabel;

@end

@implementation EmotionChartView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                    options:NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
        
        self.activeIndicator = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 1.0, 30.0)];
        [self.activeIndicator setBackgroundColor:[TPColor chartBaseLineDarkBlue]];
        self.activeIndicator.hidden = true;
        [self addSubview:self.activeIndicator];
        
        self.timeLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, 80.0, 12.0)] convertToTPLabelWithFontSize:10.0];
        self.timeLabel.textColor = [TPColor defaultBlack];
        self.timeLabel.hidden = true;
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.keyPoints && self.keyValues) {
        CGFloat x = 0;
        NSUInteger totalK = [self.keyPoints count];
        [[TPColor chartValidBlue] setFill];
        for (NSUInteger i = 1; i < totalK; i ++) {
            [[NSBezierPath bezierPathWithRect:NSMakeRect(x, 0.0, [self.keyPoints[i] floatValue] - x, [self.keyValues[i - 1] floatValue] * 6)] fill];
            x = [self.keyPoints[i] floatValue];
        }
    }
    
    NSBezierPath *baseLine = [[NSBezierPath alloc] init];
    [baseLine moveToPoint:NSMakePoint(0.0, 0.0)];
    [baseLine lineToPoint:NSMakePoint(250.0, 0.0)];
    [[TPColor chartBaseLineDarkBlue] setStroke];
    [baseLine stroke];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    self.activeIndicator.hidden = false;
    self.timeLabel.hidden = false;
    [self updateActiveIndicatorPos:[self convertPoint:theEvent.locationInWindow fromView:nil]];
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.activeIndicator.hidden = true;
    self.timeLabel.hidden = true;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [self updateActiveIndicatorPos:[self convertPoint:theEvent.locationInWindow fromView:nil]];
}

- (void)updateActiveIndicatorPos:(NSPoint) point {
    NSRect frame1 = self.activeIndicator.frame;
    frame1.origin.x = point.x - 0.5;
    self.activeIndicator.frame = frame1;
    
    NSRect frame2 = self.timeLabel.frame;
    if (point.x > 160.0) {
        frame2.origin.x = point.x - 82.0;
        self.timeLabel.alignment = NSRightTextAlignment;
    } else {
        frame2.origin.x = point.x + 2.0;
        self.timeLabel.alignment = NSLeftTextAlignment;
    }
    self.timeLabel.frame = frame2;
    
    NSTimeInterval interval = -(int)(345.6 * daysInRange * (250.0 - point.x));
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([NSDate daysFromDate:date toDate:[NSDate date]] == 0) {
        [dateFormatter setDateFormat:dateFormatTimeOnly];
    } else {
        [dateFormatter setDateFormat:dateFormatTimeAndDate];
    }
    self.timeLabel.stringValue = [dateFormatter stringFromDate:date];
}

- (void)updateChartWithCurrent:(NSNumber *)current andHistory:(NSArray *)history {
    self.keyPoints = [[NSMutableArray alloc] init];
    self.keyValues = [[NSMutableArray alloc] init];
    
    NSDate *currentTime = [NSDate date];
    
    if ([history count] == 0) {
        [self.keyPoints addObject:@(0.0)];
        [self.keyValues addObject:current];
    } else {
        PFObject *entry = [history firstObject];
        [self.keyPoints addObject:@(0.0)];
        [self.keyValues addObject:entry[@"oldValue"]];
    }
    for (PFObject *entry in history) {
        NSDate *dateInLocalTime = [[DataManager sharedManager] convertDateFromPartnerTimezoneToSelfTimezone:entry[@"postAt"]];
        NSTimeInterval interval = [currentTime timeIntervalSinceDate:dateInLocalTime];
        [self.keyPoints addObject:@(250.0 - (interval / (345.6 * daysInRange)))];
        [self.keyValues addObject:entry[@"newValue"]];
    }
    [self.keyPoints addObject:@(250.0)];
    [self.keyValues addObject:current];
    
    [self setNeedsDisplay:true];
}


@end
