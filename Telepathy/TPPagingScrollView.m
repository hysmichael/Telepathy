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

@property BOOL canRunResetAnimation;
@property BOOL willRunOrIsRunningResetAnimation;
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

- (void)scrollViewDidScroll {
    CGPoint origin = self.contentView.bounds.origin;
    
    CGPoint clingOrigin = origin;
    NSInteger xIndex = 0, yIndex = 0;
    
    if (self.horizontalPaging > 0.0 && origin.x > 0.0 && origin.x + self.bounds.size.width < ((NSView *)self.documentView).bounds.size.width)
        clingOrigin.x = round(origin.x / self.horizontalPaging) * self.horizontalPaging;
    if (self.verticalPaging > 0.0 && origin.y > 0.0 && origin.y + self.bounds.size.height > ((NSView *)self.documentView).bounds.size.height)
        clingOrigin.y = round(origin.y / self.verticalPaging) * self.verticalPaging;
    
    if (self.horizontalPaging > 0.0) {
        xIndex = (NSInteger)(clingOrigin.x / self.horizontalPaging);
        if (xIndex < 0) xIndex = 0;
        NSUInteger xBound = (NSUInteger)(((NSView *)self.documentView).bounds.size.width / self.bounds.size.width);
        if (xIndex >= xBound) xIndex = xBound - 1;
    }
    
    if (self.verticalPaging > 0.0) {
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
        [[NSAnimationContext currentContext] setDuration:0.5];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            self.willRunOrIsRunningResetAnimation = false;
            self.canRunResetAnimation = false;
        }];
        [[self.contentView animator] setBoundsOrigin:clingOrigin];
        [NSAnimationContext endGrouping];
    } else {
        self.canRunResetAnimation = false;
    }
}

- (void)contentBoundChanged {
    if (self.willRunOrIsRunningResetAnimation && self.canRunResetAnimation) {
        self.lastBoundChangeNotificationNo ++;
        NSUInteger currentNotificationNo = self.lastBoundChangeNotificationNo;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (currentNotificationNo == self.lastBoundChangeNotificationNo) {
                [self scrollViewDidScroll];
            }
        });
    }
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    if (event.type == NSEventTypeGesture && !self.willRunOrIsRunningResetAnimation) {
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if (touches.count == 2) {
            self.willRunOrIsRunningResetAnimation = true;
        }
    }
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    if (event.type == NSEventTypeGesture && self.willRunOrIsRunningResetAnimation) {
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
        if (touches.count == 2) {
            self.canRunResetAnimation = true;
            self.lastBoundChangeNotificationNo = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.lastBoundChangeNotificationNo == 0) {
                    [self scrollViewDidScroll];
                }
            });
        }
    }
}

- (void)setXPage:(NSUInteger)xPage yPage:(NSUInteger)yPage {
    [[self contentView] scrollRectToVisible:NSMakeRect(xPage * self.horizontalPaging, yPage * self.verticalPaging,
                                                       self.bounds.size.width, self.bounds.size.height)];
    self.xPage = xPage;
    self.yPage = yPage;
}


@end
