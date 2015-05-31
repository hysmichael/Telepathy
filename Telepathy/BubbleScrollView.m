//
//  MessageView.m
//  Telepathy
//
//  Created by Michael Hong on 5/17/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "BubbleScrollView.h"
#import "BubbleView.h"
#import "TPFlippedView.h"

@interface BubbleScrollView()

@property Class prototypeClass;
@property NSScrollView *bubbleCollectionView;
@property NSTextField *emptyLabel;

@end

@implementation BubbleScrollView

- (instancetype)initWithFrame:(NSRect)frame prototypeBubbleClass:(Class)className emptyMessage:(NSString *)emptyMsg {
    self = [super initWithFrame:frame];
    if (self) {
        self.prototypeClass = className;
        self.bubbleCollectionView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 260.0, frame.size.height)];
        self.bubbleCollectionView.drawsBackground = false;
        self.bubbleCollectionView.hasVerticalScroller = true;
        [self addSubview:self.bubbleCollectionView];
        CGFloat labelY = (frame.size.height - 20.0) / 2;
        self.emptyLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0.0, labelY, 260.0, 20.0)] convertToTPLabelWithFontSize:14.0];
        self.emptyLabel.textColor = [TPColor seperatorBlue];
        self.emptyLabel.alignment = NSCenterTextAlignment;
        self.emptyLabel.stringValue = emptyMsg;
        [self addSubview:self.emptyLabel];
    }
    return self;
}

- (void)reloadAllBubbleViews:(NSArray *)data {
    TPFlippedView *documentView = [[TPFlippedView alloc] init];
    self.emptyLabel.hidden = ([data count] > 0);
    CGFloat y = 0;
    for (PFObject *messageObj in data) {
        BubbleView *bubbleView = [[self.prototypeClass alloc] init];
        CGFloat bubbleHeight = [bubbleView setContentObject:messageObj];
        [bubbleView setFrame:NSMakeRect(0.0, y, 260.0, bubbleHeight)];
        y += bubbleHeight + 5.0;
        [documentView addSubview:bubbleView];
        [bubbleView addTrackingRect];
    }
    documentView.frame = NSMakeRect(0.0, 0.0, 260.0, y - 5.0);
    [self.bubbleCollectionView setDocumentView:documentView];
}

@end
