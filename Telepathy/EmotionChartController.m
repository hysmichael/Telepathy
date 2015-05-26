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

@end

@implementation EmotionChartController

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        self.view = [[EmotionChartView alloc] initWithFrame:frame];
        [parentView addSubview:self.view];
    }
    return self;
}

- (void)updateEmotionChartWidget {
    [[DataManager sharedManager] getPartnerEIndexSinceDays:daysInRange callback:^(NSArray *objs) {
        DataManager *manager = [DataManager sharedManager];
        self.indexHistory = objs;
        [self.view updateChartWithCurrent:manager.userPartner[@"currentEIndex"] history:objs activeTokens:manager.activeTokens];
    }];
    [[DataManager sharedManager] registerActiveTokensNotificationDelegate:self];
}

- (void)didUpdateActiveTokens:(NSArray *)tokens {
    DataManager *manager = [DataManager sharedManager];
    [self.view updateChartWithCurrent:manager.userPartner[@"currentEIndex"] history:self.indexHistory activeTokens:tokens];
}

@end
