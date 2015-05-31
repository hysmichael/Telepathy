//
//  TPConstraintView.m
//  Telepathy
//
//  Created by Michael Hong on 5/30/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "TPConstraintView.h"

@implementation TPConstraintView

- (NSRect)adjustScroll:(NSRect)newVisible {
    NSRect modifiedRect = newVisible;
    
    if (self.constrainHorizontalScrolling) {
        modifiedRect.origin.x = 0;
    } else {
        if (self.horizontalGrid > 0.0 && modifiedRect.origin.x > 0.0 && modifiedRect.origin.x + self.clipViewSize.width < self.bounds.size.width)
            modifiedRect.origin.x = round(modifiedRect.origin.x / self.horizontalGrid) * self.horizontalGrid;
    }
    
    if (self.constrainVerticalScrolling) {
        modifiedRect.origin.y = 0;
    } else {
        if (self.verticalGrid > 0.0 && modifiedRect.origin.y > 0.0 && modifiedRect.origin.y + self.clipViewSize.height < self.bounds.size.height)
            modifiedRect.origin.y = round(modifiedRect.origin.y / self.verticalGrid) * self.verticalGrid;
    }
    
    return modifiedRect;
}

@end
