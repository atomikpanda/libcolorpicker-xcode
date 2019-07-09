//
//  PFColor.m
//  libcolorpicker
//
//  Created by Bailey Seymour on 7/9/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "PFColor.h"
#import <UIKit/UIKit.h>

@implementation PFColor

// Constructors

- (instancetype)init {
    if ((self = [super init])) {
        self.red = 1.0f;
        self.green = 1.0f;
        self.blue = 1.0f;
        self.alpha = 1.0f;
    }
    
    return self;
}

- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    if ((self = [self init])) {
        self.red = red;
        self.green = green;
        self.blue = blue;
        self.alpha = alpha;
    }
    
    return self;
}

- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [self initWithRed:red green:green blue:blue alpha:1.0f];
}

- (instancetype)initWithHex:(NSString *)hexString {
    if ((self = [self init])) {
        [self setValuesFromHex:hexString];
    }
    return self;
}


// Factory methods

+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [[self alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [[self alloc] initWithRed:red green:green blue:blue];
}

// Properties

- (void)setRed:(CGFloat)red {
    _red = [PFColor limitColorValue:red];
}

- (void)setGreen:(CGFloat)green {
    _green = [PFColor limitColorValue:green];
}

- (void)setBlue:(CGFloat)blue {
    _blue = [PFColor limitColorValue:blue];
}

- (void)setAlpha:(CGFloat)alpha {
    _alpha = [PFColor limitColorValue:alpha];
}

- (void)setValuesFromHex:(NSString *)stringContainingHex {
    
    if (!stringContainingHex) return;
    
    CGFloat r, g, b, a;
    [PFColor sanitizeAndParseHex:stringContainingHex red:&r green:&g blue:&b alpha:&a];
    self.red = r;
    self.green = g;
    self.blue = b;
    self.alpha = a;
}

// Class methods

+ (CGFloat)limitColorValue:(CGFloat)value {
    return fmax(0.0f, fmin(1.0f, value));
}

+ (void)parseRGBHex:(NSString *)hexString red:(CGFloat *)outRed green:(CGFloat *)outGreen blue:(CGFloat *)outBlue {
    NSCAssert((hexString.length == 6 || hexString.length == 3), @"requires a 3 or 6 character hex string.");
    
    // support 3 char hex
    if (hexString.length == 3) {
        hexString = [hexString stringByAppendingString:hexString];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned fullHexInt;
    [scanner scanHexInt:&fullHexInt];
    
    *outRed = ((fullHexInt & 0xff0000) >> 16) / 255.0f;
    *outGreen = ((fullHexInt & 0x00ff00) >> 8) / 255.0f;
    *outBlue = ((fullHexInt & 0x0000ff)) / 255.0f;
}

+ (void)sanitizeAndParseHex:(NSString *)stringContainingHex red:(CGFloat *)outRed green:(CGFloat *)outGreen blue:(CGFloat *)outBlue alpha:(CGFloat *)outAlpha {
    
    if (!stringContainingHex) return;
    
    NSError *err;
    // ((?:#|^)((?:(?:[A-Fa-f]|\d){3}){1,2})(?::((?:\d|\.)+))?)
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?:#|^)((?:(?:[A-Fa-f]|\\d){3}){1,2})(?::((?:\\d|\\.)+))?)" options:0 error:&err];
    
    if (err)
        NSLog(@"REGEX ERR: %@", err.localizedDescription);
    
    if (regex) {
        NSTextCheckingResult *match = [regex firstMatchInString:stringContainingHex options:0 range:NSMakeRange(0, stringContainingHex.length)];
        
        if (!match) return;
        
        NSArray *matches = _LCPGroupsFromMatch(match, stringContainingHex);
        
        NSString *hexString;
        
        if (matches.count == 3 || matches.count == 4) {
            // Hex code
            hexString = matches[2];
        }
        
        float alphaValue = 1.0f;
        if (matches.count == 4 && hexString) {
            // Handle alpha
            
            NSScanner *scanner = [NSScanner scannerWithString:matches[3]];
            if (!([scanner scanFloat:&alphaValue] && [scanner isAtEnd])) {
                alphaValue = 1.0f;
            }
        }
        
        // RGB
        [self parseRGBHex:hexString red:outRed green:outGreen blue:outBlue];
        
        // Set alpha
        *outAlpha = alphaValue;
    }
}

// FIXME: make an objc method
NSArray *_LCPGroupsFromMatch(NSTextCheckingResult *matchResult, NSString *originalString) {
    NSMutableArray *matches = [NSMutableArray array];
    
    if (matchResult && originalString) {
        for (int i=0; i < matchResult.numberOfRanges; i++) {
            NSRange matchRange = [matchResult rangeAtIndex:i];
            if (matchRange.location == NSNotFound) continue;
            
            NSString *matchStr = [originalString substringWithRange:matchRange];
            
            [matches addObject:matchStr];
        }
    }
    
    return matches;
}

- (NSString *)hexString {
    return [[NSString stringWithFormat:@"#%02X%02X%02X",
             (int)(self.red * 255), (int)(self.green * 255), (int)(self.blue * 255)]
            uppercaseString];
}

- (UIColor *)UIColor {
    return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}

@end
