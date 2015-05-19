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
+ (NSColor *) mediumGray;           // 9B9B9B
+ (NSColor *) lightGray;            // EAEAEA

+ (NSColor *) green;                        // 9CE255
+ (NSColor *) lightMint:(CGFloat)alpha;     // 95F1D6
+ (NSColor *) darkMint;                     // 7CD5C0

+ (NSColor *) lightPurple:(CGFloat)alpha;   // DFCDFF
+ (NSColor *) mediumPurple;                 // C993FF
+ (NSColor *) darkPurple:(CGFloat)alpha;    // A776FF

+ (NSColor *) lightBlue:(CGFloat)alpha;   // CFF2FF
+ (NSColor *) mediumBlue;                 // 8BC1FF
+ (NSColor *) darkBlue:(CGFloat)alpha;    // 60CDF5
+ (NSColor *) seperatorBlue;              // B1CCDC

+ (NSColor *) chartBaseLineDarkBlue;      // 1B3592
+ (NSColor *) chartValidBlue;             // B6C3F2
+ (NSColor *) chartInvalidBlue;           // E4E9FB

@end
