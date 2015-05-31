//
//  TPPagingScrollView.h
//  Telepathy
//
//  Created by Michael Hong on 5/30/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPPagingScrollView : NSScrollView

@property CGFloat horizontalPaging;
@property CGFloat verticalPaging;

@property (copy) void(^didScrollToPage)(NSUInteger, NSUInteger);

- (void) setXPage:(NSUInteger) xPage yPage:(NSUInteger) yPage;

@end
