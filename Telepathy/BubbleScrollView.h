//
//  MessageView.h
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BubbleScrollView : NSView

- (instancetype)initWithFrame:(NSRect)frame prototypeBubbleClass:(Class)className emptyMessage:(NSString *)emptyMsg;
- (void) reloadAllBubbleViews:(NSArray *) data;

@end
