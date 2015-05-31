//
//  EmotionChartController.m
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "EmotionChartController.h"

@interface EmotionChartController()

@property NSArray *indexHistory;
@property NSPanGestureRecognizer *gestureRecognizer;

@end

@implementation EmotionChartController

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        self.view = [[EmotionChartView alloc] initWithFrame:frame];
        self.view.controller = self;
        [parentView addSubview:self.view];
    }
    return self;
}

- (void)updateEmotionChartWidget {
    [[DataManager sharedManager] getPartnerEIndexSinceDays:7 callback:^(NSArray *objs) {
        self.indexHistory = objs;
        [self refreshChart];
    }];
    [[DataManager sharedManager] registerActiveTokensNotificationDelegate:self];
}

- (void)didUpdateActiveTokens:(NSArray *)tokens {
    [self refreshChart];
}

- (void)refreshChart {
    DataManager *manager = [DataManager sharedManager];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(self.view.daysInRange * (3600 * 24))];
    
    NSUInteger startIndex = [self.indexHistory indexOfObjectPassingTest:^BOOL(PFObject * obj, NSUInteger idx, BOOL *stop) {
        return ([obj[@"postAt"] timeIntervalSinceDate:date] >= 0);
    }];
    NSArray *filteredIndexArray;
    if (startIndex != NSNotFound) {
        filteredIndexArray = [self.indexHistory subarrayWithRange:NSMakeRange(startIndex, [self.indexHistory count] - startIndex)];
    } else {
        filteredIndexArray = [NSArray array];
    }
    
    startIndex = [manager.activeTokens indexOfObjectPassingTest:^BOOL(PFObject * obj, NSUInteger idx, BOOL *stop) {
        return ([obj.createdAt timeIntervalSinceDate:date] >= 0);
    }];
    NSArray *filteredTokenArray;
    if (startIndex != NSNotFound) {
        filteredTokenArray = [manager.activeTokens subarrayWithRange:NSMakeRange(startIndex, [manager.activeTokens count] - startIndex)];
    } else {
        filteredTokenArray = [NSArray array];
    }
    
    [self.view updateChartWithCurrent:manager.userPartner[@"currentEIndex"] history:filteredIndexArray activeTokens:filteredTokenArray];
}

@end
