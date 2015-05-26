//
//  EmotionChartController.h
//  Telepathy
//
//  Created by Michael Hong on 5/19/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmotionChartView.h"

@interface EmotionChartController : NSObject<ActiveTokensNotificationDelegate>

@property EmotionChartView *view;

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView;

- (void) updateEmotionChartWidget;

@end
