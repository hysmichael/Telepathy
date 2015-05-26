//
//  TPColor.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "TPColor.h"

@implementation TPColor

+ (NSColor *) colorWithHex:(NSString *)hexStr alpha:(CGFloat)alpha {
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
        
    if (hexStr) {
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        (void) [scanner scanHexInt:&colorCode];
    }
    
    redByte     = (unsigned char)(colorCode >> 16);
    greenByte   = (unsigned char)(colorCode >> 8);
    blueByte    = (unsigned char)(colorCode);
    
    result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff
                                       green:(CGFloat)greenByte / 0xff
                                        blue:(CGFloat)blueByte / 0xff
                                       alpha:alpha];
    
    return result;
}

+ (NSColor *)defaultBlack {
    return [self colorWithHex:@"4A4A4A" alpha:1.0];
}

+ (NSColor *)darkGray {
    return [self colorWithHex:@"6B6565" alpha:1.0];
}

+ (NSColor *)mediumGray {
    return [self colorWithHex:@"9B9B9B" alpha:1.0];
}

+ (NSColor *)lightGray {
    return [self colorWithHex:@"EAEAEA" alpha:1.0];
}



+ (NSColor *)green {
    return [self colorWithHex:@"9CE255" alpha:1.0];
}

+ (NSColor *)lightMint:(CGFloat)alpha {
    return [self colorWithHex:@"95F1D6" alpha:alpha];
}

+ (NSColor *)darkMint {
    return [self colorWithHex:@"7CD5C0" alpha:1.0];
}


+ (NSColor *)lightPurple:(CGFloat)alpha {
    return [self colorWithHex:@"DFCDFF" alpha:alpha];
}

+ (NSColor *)mediumPurple {
    return [self colorWithHex:@"C993FF" alpha:1.0];
}

+ (NSColor *)darkPurple:(CGFloat)alpha {
    return [self colorWithHex:@"A776FF" alpha:alpha];
}



+ (NSColor *)lightBlue:(CGFloat)alpha {
    return [self colorWithHex:@"CFF2FF" alpha:alpha];
}

+ (NSColor *)mediumBlue {
    return [self colorWithHex:@"8BC1FF" alpha:1.0];
}

+ (NSColor *)darkBlue:(CGFloat)alpha {
    return [self colorWithHex:@"60CDF5" alpha:alpha];
}

+ (NSColor *)seperatorBlue {
    return [self colorWithHex:@"B1CCDC" alpha:0.8];
}



+ (NSColor *)chartBaseLineDarkBlue {
    return [self colorWithHex:@"1B3592" alpha:1.0];
}

+ (NSColor *)chartValidBlue {
    return [self colorWithHex:@"B6C3F2" alpha:1.0];
}

+ (NSColor *)chartInvalidBlue {
    return [self colorWithHex:@"B6C3F2" alpha:0.3];
}

@end
