//
//  TPPagingScrollView.m
//  Telepathy
//
//  Created by Michael Hong on 5/30/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "TPPagingScrollView.h"

@interface TPPagingScrollView()

@property NSUInteger xPage;
@property NSUInteger yPage;

@property NSUInteger lastBoundChangeNotificationNo;

@end

@implementation TPPagingScrollView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAcceptsTouchEvents:true];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentBoundChanged)
                                                     name:NSViewBoundsDidChangeNotification object:self.contentView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:self.contentView];
}

- (void)scrollViewClingToPage {
    CGPoint origin = self.contentView.bounds.origin;
    
    CGPoint clingOrigin = origin;
    NSInteger xIndex = 0, yIndex = 0;
    
    if (self.horizontalPaging > 0.0) {
        clingOrigin.x = round(origin.x / self.horizontalPaging) * self.horizontalPaging;
        xIndex = (NSInteger)(clingOrigin.x / self.horizontalPaging);
        if (xIndex < 0) xIndex = 0;
        NSUInteger xBound = (NSUInteger)(((NSView *)self.documentView).bounds.size.width / self.bounds.size.width);
        if (xIndex >= xBound) xIndex = xBound - 1;
    }
    
    if (self.verticalPaging > 0.0) {
        clingOrigin.y = round(origin.y / self.verticalPaging) * self.verticalPaging;
        yIndex = (NSInteger)(clingOrigin.y / self.verticalPaging);
        if (yIndex < 0) yIndex = 0;
        NSUInteger yBound = (NSUInteger)(((NSView *)self.documentView).bounds.size.height / self.bounds.size.height);
        if (yIndex >= yBound) yIndex = yBound - 1;
    }

    if (self.didScrollToPage && (self.xPage != xIndex || self.yPage != yIndex)) {
        self.xPage = xIndex;
        self.yPage = yIndex;
        self.didScrollToPage(xIndex, yIndex);
    }
    
    if (origin.x != clingOrigin.x || origin.y != clingOrigin.y) {
        [NSAnimationContext beginGrouping];
        CGFloat animationTime = sqrt(pow(origin.x - clingOrigin.x, 2) / pow(self.bounds.size.width, 2) +
                                     pow(origin.y - clingOrigin.y, 2) / pow(self.bounds.size.height, 2));
        if (animationTime > 0.5) animationTime = 0.5;
        [[NSAnimationContext currentContext] setDuration:animationTime];
        [[self.contentView animator] setBoundsOrigin:clingOrigin];
        [NSAnimationContext endGrouping];
    }
}

- (void)contentBoundChanged {
    self.lastBoundChangeNotificationNo ++;
    NSUInteger currentNotificationNo = self.lastBoundChangeNotificationNo;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (currentNotificationNo == self.lastBoundChangeNotificationNo) {
            /* bounds haven't been changed within 0.05 seconds
             (suggests that bounds animation has come to a stop)
               reset bounds if it stops at an improper location */
            self.lastBoundChangeNotificationNo = 0;
            [self scrollViewClingToPage];
        }
    });
}

- (void)setXPage:(NSUInteger)xPage yPage:(NSUInteger)yPage {
    [[self contentView] scrollRectToVisible:NSMakeRect(xPage * self.horizontalPaging, yPage * self.verticalPaging,
                                                       self.bounds.size.width, self.bounds.size.height)];
    self.xPage = xPage;
    self.yPage = yPage;
}


@end
