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

+ (NSColor *)green {
    return [self colorWithHex:@"9CE255" alpha:1.0];
}

+ (NSColor *)defaultBlack {
    return [self colorWithHex:@"4A4A4A" alpha:1.0];
}

+ (NSColor *)darkGray {
    return [self colorWithHex:@"6B6565" alpha:1.0];
}

+ (NSColor *)mediumGray {
    return [self colorWithHex:@"857889" alpha:1.0];
}


+ (NSColor *)lightMint:(CGFloat)alpha {
    return [self colorWithHex:@"95F1D6" alpha:alpha];
}

+ (NSColor *)darkMint {
    return [self colorWithHex:@"7CD5C0" alpha:1.0];
}

@end
