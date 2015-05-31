//
//  AnniversaryView.m
//  Telepathy
//
//  Created by Michael Hong on 5/10/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "AnniversaryView.h"
#import "TPPagingScrollView.h"
#import "TPConstraintView.h"

@interface AnniversaryView()

@property (nonatomic, retain) NSTextField *daysLabel;
@property (nonatomic, retain) TPPagingScrollView *scrollView;

@property NSArray *dataArray;

@end

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
        
        self.scrollView = [[TPPagingScrollView alloc] initWithFrame:NSMakeRect(10.0, 0.0, 160.0, 30.0)];
        self.scrollView.drawsBackground = false;
        self.scrollView.horizontalPaging = 160.0;
        
        __weak AnniversaryView *weakSelf = self;
        [self.scrollView setDidScrollToPage:^(NSUInteger x, NSUInteger y) {
            if (x < [self.dataArray count]) weakSelf.daysLabel.stringValue = weakSelf.dataArray[x][@"days"];
        }];
        
        [self addSubview:self.scrollView];
        
        self.daysLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(0., 7.0, 80.0, 15.0)] convertToTPLabelWithFontSize:12.0];
        self.daysLabel.alignment = NSCenterTextAlignment;
        [self.daysLabel setTextColor:[TPColor defaultBlack]];
        [innerBoxView addSubview:self.daysLabel];
    }
    return self;
}

- (void)setAnniversaryData:(NSArray *)data defaultIndex:(NSUInteger)index {
    TPConstraintView *documentView = [[TPConstraintView alloc] init];
    documentView.constrainVerticalScrolling = true;
    CGFloat x = 0;
    for (NSDictionary *anniversary in data) {
        NSTextField *titleLabel = [[[NSTextField alloc] initWithFrame:NSMakeRect(x, 7.0, 160.0, 15.0)] convertToTPLabelWithFontSize:12.0];
        [titleLabel setTextColor:[TPColor darkGray]];
        titleLabel.stringValue = anniversary[@"title"];
        [documentView addSubview:titleLabel];
        x += 160.0;
    }
    documentView.frame = NSMakeRect(0.0, 0.0, x, 30.0);
    [self.scrollView setDocumentView:documentView];
    
    [self.scrollView setXPage:index yPage:0];
    self.daysLabel.stringValue = [data firstObject][@"days"];
    self.dataArray = data;
}

@end
