//
//  Extension.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "Extension.h"

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

@end