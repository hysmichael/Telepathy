//
//  BubbleView.h
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* This is the base class for all bubble-based views that will be 
    populated into BubbleScrollView. */
@interface BubbleView : NSView

/* Configure the bubble content with model object and returns the proper bubble height. */
- (CGFloat) setContentObject:(id)object;

@end
