//
//  Extension.h
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTextField (TPTextField)

- (NSTextField *) convertToTPLabel;
- (NSTextField *) convertToTPLabelWithFontSize:(CGFloat) fontsize;

@end

@interface NSFont (TPFont)

+ (NSFont *) TPFontWithSize:(CGFloat) size;

@end

@interface NSView (TPView)

- (void) setBackgroundColor:(NSColor *)color;
- (void) setBackgroundColorWithCGColorRef:(CGColorRef)color;
- (void) setBoarderRadius:(CGFloat)radius color:(NSColor *)color width:(CGFloat)width;
- (void) strokeLineFromPoint:(NSPoint)point length:(CGFloat)length width:(CGFloat)width color:(NSColor *)color;

@end

@interface NSDate (TPDate)

+ (NSInteger)daysFromDate:(NSDate*)fromDateTime toDate:(NSDate*)toDateTime;

@end