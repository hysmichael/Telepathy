//
//  TPTextField.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "TPTextField.h"

@implementation TPTextField

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self convertToTPLabel];
    }
    return self;
}

-(NSSize)intrinsicContentSize
{
    if (![self.cell wraps]) {
        return [super intrinsicContentSize];
    }
    
    NSRect frame = [self frame];
    CGFloat width = frame.size.width;
    
    // Make the frame very high, while keeping the width
    frame.size.height = CGFLOAT_MAX;
    
    // Calculate new height within the frame
    // with practically infinite height.
    CGFloat height = [self.cell cellSizeForBounds: frame].height;
    
    return NSMakeSize(width, height);
}

- (void)sizeToFit {
    NSSize size = [self intrinsicContentSize];
    self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

@end
