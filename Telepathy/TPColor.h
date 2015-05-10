//
//  TPColor.h
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPColor : NSObject

+ (NSColor *) defaultBlack;         // 4A4A4A
+ (NSColor *) darkGray;             // 6B6565
+ (NSColor *) mediumGray;           // 857889

+ (NSColor *) green;                        // 9CE255
+ (NSColor *) lightMint:(CGFloat)alpha;     // 95F1D6
+ (NSColor *) darkMint;                     // 7CD5C0

@end
