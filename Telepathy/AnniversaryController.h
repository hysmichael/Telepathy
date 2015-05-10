//
//  AnniversaryController.h
//  Telepathy
//
//  Created by Michael Hong on 5/10/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnniversaryView.h"

@interface AnniversaryController : NSObject

@property (nonatomic, retain) AnniversaryView *view;

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView;
- (void) updateAnniversaryWidget;

@end
