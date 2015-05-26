//
//  EventBubbleView.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EventBubbleView.h"
#import "DateFormats.h"

@interface EventBubbleView()

@property NSTextField *titleLabel;
@property NSTextField *timeLabel;
@property NSView *progressView;

@end

@implementation EventBubbleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.progressView = [[NSView alloc] init];
        [self.progressView setBackgroundColor:[TPColor darkBlue:0.6]];
        self.progressView.layer.cornerRadius = 10.0;
        
        [self addSubview:self.progressView];
        
        self.titleLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(10.0, 17.0, 240.0, 15.0)] convertToTPLabel];
        self.titleLabel.font = [NSFont TPFontWithSize:12.0];
        self.titleLabel.textColor = [TPColor defaultBlack];
        
        self.timeLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(10.0, 7.0, 240.0, 11.0)] convertToTPLabel];
        self.timeLabel.font = [NSFont TPFontWithSize:10.0];
        self.timeLabel.textColor = [TPColor mediumGray];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.timeLabel];
        
        [self setBackgroundColor:[TPColor lightBlue:50.0]];
        [self setBoarderRadius:10.0 color:[TPColor mediumBlue] width:2.0];
    }
    return self;
}

- (CGFloat)setContentObject:(id)object {
    
    self.titleLabel.stringValue = object[@"title"];
    
    NSDate *startDateInLocalTime = object[@"startDate"];
    NSDate *endDateInLocalTime = object[@"endDate"];
    
    NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
    if ([NSDate daysFromDate:startDateInLocalTime toDate:endDateInLocalTime] == 0) {
        [startDateFormatter setDateFormat:dateFormatTimeOnly];
    } else {
        [startDateFormatter setDateFormat:dateFormatTimeAndDate];
    }
    
    NSDateFormatter *endDateFormatter = [[NSDateFormatter alloc] init];
    [endDateFormatter setDateFormat:dateFormatTimeAndDate];
    
    NSString *startDateStr = [startDateFormatter stringFromDate:startDateInLocalTime];
    NSString *endDateStr = [endDateFormatter stringFromDate:endDateInLocalTime];
    
    self.timeLabel.stringValue = [NSString stringWithFormat:@"%@ 〜 %@", startDateStr, endDateStr];
    
    NSTimeInterval totalLength = [endDateInLocalTime timeIntervalSinceDate:startDateInLocalTime];
    NSTimeInterval elapsedLength = [[NSDate date] timeIntervalSinceDate:startDateInLocalTime];
    float pct = (float)elapsedLength / (float)totalLength;
    if (pct < 0.0) pct = 0.0;
    if (pct > 1.0) pct = 1.0;
    self.progressView.frame = NSMakeRect(0.0, 0.0, pct * 260.0, 40.0);
    
    return 40.0;
}

@end
