//
//  BubbleView.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "BubbleView.h"

@interface BubbleView()

@property BOOL addedTrackingRect;

@end

@implementation BubbleView

- (CGFloat)setContentObject:(id)object {
    return 0.0;
}

- (void)addTrackingRect {
    if (!self.addedTrackingRect) {
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:false];
        self.addedTrackingRect = true;
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSColor *color = [NSColor colorWithCGColor:self.layer.backgroundColor];
    NSColor *newColor = [color colorWithAlphaComponent:1.0];
    self.layer.backgroundColor = newColor.CGColor;
}

- (void)mouseExited:(NSEvent *)theEvent {
    NSColor *color = [NSColor colorWithCGColor:self.layer.backgroundColor];
    NSColor *newColor = [color colorWithAlphaComponent:0.5];
    self.layer.backgroundColor = newColor.CGColor;
}


@end


