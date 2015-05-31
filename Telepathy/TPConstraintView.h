//
//  TPConstraintView.h
//  Telepathy
//
//  Created by Michael Hong on 5/30/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPConstraintView : NSView

@property CGFloat horizontalGrid;
@property CGFloat verticalGrid;

@property CGSize  clipViewSize;

@property BOOL constrainHorizontalScrolling;
@property BOOL constrainVerticalScrolling;

@end
