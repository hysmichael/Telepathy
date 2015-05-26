//
//  Extension.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "Extension.h"
#import "DateFormats.h"

@implementation NSTextField (TPTextField)

- (NSTextField *)convertToTPLabel {
    [self setBezeled:false];
    [self setBordered:false];
    self.backgroundColor = [NSColor clearColor];
    [self setEditable:false];
    [self setSelectable:false];
    return self;
}

- (NSTextField *) convertToTPLabelWithFontSize:(CGFloat)fontsize {
    [self convertToTPLabel];
    [self setFont:[NSFont TPFontWithSize:fontsize]];
    return self;
}

@end

@implementation NSFont (TPFont)

// SourceHanSans-Regular
+ (NSFont *)TPFontWithSize:(CGFloat)size {
    return [NSFont fontWithName:@"SourceHanSans-Regular" size:size];
}

@end

@implementation NSView (TPView)

- (void)setBackgroundColor:(NSColor *)color {
    [self setBackgroundColorWithCGColorRef:color.CGColor];
}

- (void)setBackgroundColorWithCGColorRef:(CGColorRef)color {
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setBackgroundColor:color];
    self.wantsLayer = true;
    self.layer = backgroundLayer;
}

- (void)setBoarderRadius:(CGFloat)radius color:(NSColor *)color width:(CGFloat)width {
    self.wantsLayer = true;
    self.layer.cornerRadius = radius;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.layer.masksToBounds = true;
}

- (void)strokeLineFromPoint:(NSPoint)point length:(CGFloat)length width:(CGFloat)width color:(NSColor *)color {
    NSView *lineView = [[NSView alloc] initWithFrame:NSMakeRect(point.x, point.y - width / 2, length, width)];
    [lineView setBackgroundColor:color];
    [self addSubview:lineView];
}

@end

@implementation NSDate (TPDate)

+ (NSInteger)daysFromDate:(NSDate *)fromDateTime toDate:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

- (NSString *)smartDescription {
    NSInteger days = labs([NSDate daysFromDate:self toDate:[NSDate date]]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (days == 0) {
        [dateFormatter setDateFormat:dateFormatTimeOnly];
    } else if (days < 7) {
        [dateFormatter setDateFormat:dateFormatTimeAndDay];
    } else {
        [dateFormatter setDateFormat:dateFormatTimeAndDate];
    }
    return [dateFormatter stringFromDate:self];
}

@end


@implementation NSImage (TPImage)

- (NSImage *)imageTintedWithColor:(NSColor *)tint
{
    NSImage *image = [self copy];
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [image unlockFocus];
    }
    return image;
}


@end


