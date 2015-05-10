//
//  AnniversaryView.m
//  Telepathy
//
//  Created by Michael Hong on 5/10/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "AnniversaryView.h"

@implementation AnniversaryView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[TPColor lightMint:0.5]];
        [self setBoarderRadius:10.0 color:[TPColor darkMint] width:2.0];
        
        NSView *innerBoxView = [[NSView alloc] initWithFrame:NSMakeRect(180.0, 0.0, 80.0, 30.0)];
        [innerBoxView setBackgroundColor:[TPColor lightMint:0.8]];
        [innerBoxView setBoarderRadius:10.0 color:[TPColor darkMint] width:1.0];
        [self addSubview:innerBoxView];
        
        self.titleLable = [[[NSTextField alloc] initWithFrame:NSMakeRect(10.0, 7.0, 160.0, 15.0)] convertToTPLabelWithFontSize:12.0];
        [self.titleLable setTextColor:[TPColor darkGray]];
        [self addSubview:self.titleLable];
        
        self.daysLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0., 7.0, 80.0, 15.0)] convertToTPLabelWithFontSize:12.0];
        self.daysLabel.alignment = NSCenterTextAlignment;
        [self.daysLabel setTextColor:[TPColor defaultBlack]];
        [innerBoxView addSubview:self.daysLabel];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
