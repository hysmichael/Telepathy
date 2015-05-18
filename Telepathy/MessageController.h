//
//  MessageController.h
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleScrollView.h"

@interface MessageController : NSObject <NSCollectionViewDelegate>

@property (nonatomic, retain) BubbleScrollView *view;

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView;
- (void) updateMessageWidget;

@end
