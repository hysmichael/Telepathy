//
//  EmotionChartView.m
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EmotionChartView.h"
#import "DateFormats.h"
#import "EmotionChartController.h"

@interface EmotionChartView()

@property NSMutableArray *keyPoints;
@property NSMutableDictionary *keyValues;
@property NSMutableDictionary *activePeriodKeyStatus;
@property BOOL defaultAsActive;

@property CGFloat todayWedge;

@property NSView *activeIndicator;
@property NSTextField *timeLabel;
@property NSPoint lastCursorPos;

@property CGFloat swipeX;

@end

@implementation EmotionChartView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.daysInRange = 7.0;
        
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                    options:NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
        [self setAcceptsTouchEvents:true];
        
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
    
    if (self.defaultAsActive) {
        [[TPColor chartValidBlue] setFill];
    } else {
        [[TPColor chartInvalidBlue] setFill];
    }
    
    if (self.keyPoints && [self.keyPoints count] > 0) {
        CGFloat x = 0;
        CGFloat height = 0;
        NSUInteger totalK = [self.keyPoints count];
        for (NSUInteger i = 0; i < totalK - 1; i ++) {
            NSNumber *keyPoint = self.keyPoints[i];
            x = [keyPoint floatValue];
            if (self.keyValues[keyPoint]) {
                height = [self.keyValues[keyPoint] floatValue] * 6;
            }
            if (self.activePeriodKeyStatus[keyPoint]) {
                if ([self.activePeriodKeyStatus[keyPoint] boolValue]) {
                    [[TPColor chartValidBlue] setFill];
                } else {
                    [[TPColor chartInvalidBlue] setFill];
                }
            }
            [[NSBezierPath bezierPathWithRect:NSMakeRect(x, 0.0, [self.keyPoints[i + 1] floatValue] - x, height)] fill];
        }
    }
    
    
    [[TPColor chartBaseLineDarkBlue] setStroke];
    CGFloat x = self.todayWedge;
    while (x >= 0.0) {
        NSBezierPath *dayWedge = [[NSBezierPath alloc] init];
        [dayWedge moveToPoint:NSMakePoint(x, 0.0)];
        [dayWedge lineToPoint:NSMakePoint(x, 5.0)];
        [dayWedge setLineWidth:0.5];
        [dayWedge stroke];
        x -= (250.0 / self.daysInRange);
    }
    NSBezierPath *baseLine = [[NSBezierPath alloc] init];
    [baseLine moveToPoint:NSMakePoint(0.0, 0.5)];
    [baseLine lineToPoint:NSMakePoint(250.0, 0.5)];
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
    self.lastCursorPos = point;
    
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
    
    NSTimeInterval interval = -(int)(345.6 * self.daysInRange * (250.0 - point.x));
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
    self.timeLabel.stringValue = [date smartDescription];
}

- (void)updateChartWithCurrent:(NSNumber *)current history:(NSArray *)history activeTokens:(NSArray *)tokens {
    self.keyPoints = [[NSMutableArray alloc] init];
    self.keyValues = [[NSMutableDictionary alloc] init];
    
    NSDate *currentTime = [NSDate date];
    
    if ([history count] == 0) {
        [self.keyPoints addObject:@(0.0)];
        self.keyValues[@(0.0)] = current;
    } else {
        PFObject *entry = [history firstObject];
        [self.keyPoints addObject:@(0.0)];
        self.keyValues[@(0.0)] = entry[@"oldValue"];
    }
    for (PFObject *entry in history) {
        NSDate *dateInLocalTime = entry[@"postAt"];
        NSTimeInterval interval = [currentTime timeIntervalSinceDate:dateInLocalTime];
        NSNumber *keyPoint = @(250.0 - (interval / (345.6 * self.daysInRange)));
        [self.keyPoints addObject:keyPoint];
        self.keyValues[keyPoint] = entry[@"newValue"];
    }
    [self.keyPoints addObject:@(250.0)];
    self.keyValues[@(250.0)] = current;
    
    NSMutableArray *activePeriods = [[NSMutableArray alloc] init];
    for (PFObject *token in tokens) {
        NSMutableDictionary *lastActivePeriod = [activePeriods lastObject];
        NSMutableDictionary *newActivePeriod = nil;
        if (!lastActivePeriod || ([token.createdAt timeIntervalSinceDate:lastActivePeriod[@"end"]] > 0)) {
            newActivePeriod = [[NSMutableDictionary alloc] init];
            newActivePeriod[@"start"] = token.createdAt;
            newActivePeriod[@"end"] = [token.createdAt dateByAddingTimeInterval:900];
            [activePeriods addObject:newActivePeriod];
        } else {
            lastActivePeriod[@"end"] = [token.createdAt dateByAddingTimeInterval:900];
        }
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    self.defaultAsActive = false;
    if (tokens && [tokens count] > 0) {
        NSTimeInterval interval = (NSTimeInterval)((self.daysInRange * 24 * 3600) - 900);
        NSDate *startDate = [NSDate dateWithTimeInterval:-interval sinceDate:currentTime];
        PFObject *token = [tokens firstObject];
        if ([startDate timeIntervalSinceDate:token.createdAt] > 0) self.defaultAsActive = true;
    }
    
    self.activePeriodKeyStatus = [[NSMutableDictionary alloc] init];
    for (NSDictionary *period in activePeriods) {
        NSNumber *startPoint = @(250.0 - ([currentTime timeIntervalSinceDate:period[@"start"]] / (345.6 * self.daysInRange)));
        NSNumber *endPoint = @(250.0 - ([currentTime timeIntervalSinceDate:period[@"end"]] / (345.6 * self.daysInRange)));
        [self.keyPoints addObject:startPoint];
        [self.keyPoints addObject:endPoint];
        self.activePeriodKeyStatus[startPoint] = @true;
        self.activePeriodKeyStatus[endPoint] = @false;
    }
    
    [self.keyPoints sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSCalendarUnit preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *components = [calendar components:preservedComponents fromDate:currentTime];
    NSDate *normalizedDate = [calendar dateFromComponents:components];
    self.todayWedge = (250.0 - [currentTime timeIntervalSinceDate:normalizedDate] / (345.6 * self.daysInRange));
    
    [self setNeedsDisplay:true];
    
    [self updateActiveIndicatorPos:self.lastCursorPos];
}


- (void)touchesBeganWithEvent:(NSEvent *)event {
    if (event.type == NSEventTypeGesture) {
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if (touches.count == 2) {
            self.swipeX = 0.0;
            for (NSTouch *touch in touches) {
                self.swipeX += touch.normalizedPosition.x;
            }
        }
    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    if (event.type == NSEventTypeGesture) {
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if (touches.count == 2) {
            CGFloat newSwipeX = 0.0;
            for (NSTouch *touch in touches) {
                newSwipeX += touch.normalizedPosition.x;
            }
            CGFloat delta = (newSwipeX - self.swipeX) * 4.0;
            self.swipeX = newSwipeX;
            self.daysInRange += delta;
            if (self.daysInRange <= 1.0) self.daysInRange = 1.0;
            if (self.daysInRange >= 7.0) self.daysInRange = 7.0;
            [self.controller refreshChart];
        }
    }
}

@end



