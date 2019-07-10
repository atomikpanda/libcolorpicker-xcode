#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PFColor.h"


UIColor *colorFromHex(NSString *hexString);
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);
UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback);
PFColor *_LCPRGBColorFromHex(NSString *hexString);

UIColor *colorFromHex(NSString *hexString) {
    PFColor *color = _LCPRGBColorFromHex(hexString);
    return color.UIColor;
}

// do not use this method anymore
__attribute__((deprecated))
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback) {
    NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaults]];
    //fallback
    UIColor *fallbackColor = colorFromHex(fallback);
    CGFloat currentAlpha = 1.0f;

    if (preferencesPlist && [preferencesPlist objectForKey:key]) {
        NSString *value = [preferencesPlist objectForKey:key];
        NSArray *colorAndOrAlpha = [value componentsSeparatedByString:@":"];
        if ([value rangeOfString:@":"].location != NSNotFound) {
            if ([colorAndOrAlpha objectAtIndex:1])
                currentAlpha = [colorAndOrAlpha[1] floatValue];
            else
                currentAlpha = 1;
        }

        if (!value)
            return fallbackColor;

        NSString *color = colorAndOrAlpha[0];

        return [colorFromHex(color) colorWithAlphaComponent:currentAlpha];
    } else {
        return fallbackColor;
    }
}

PFColor *_LCPRGBColorFromHex(NSString *hexString) {
    NSCAssert((hexString.length == 6 || hexString.length == 3), @"requires a 3 or 6 character hex string.");
    
    // support 3 char hex
    if (hexString.length == 3) {
        hexString = [hexString stringByAppendingString:hexString];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned fullHexInt;
    [scanner scanHexInt:&fullHexInt];
    
    return [PFColor colorWithRed:(fullHexInt & 0xFF) >> 24 green:(fullHexInt & 0xFF00) >> 16 blue:(fullHexInt & 0xFF0000)];
}

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

UIColor *_LCPParseHex(NSString *stringContainingHex) {
    
    UIColor *parsedColor = nil;
    
    if (!stringContainingHex) return parsedColor;
    
    NSError *err;
    // ((?:#|^)((?:(?:[A-Fa-f]|\d){3}){1,2})(?::((?:\d|\.)+))?)
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?:#|^)((?:(?:[A-Fa-f]|\\d){3}){1,2})(?::((?:\\d|\\.)+))?)" options:0 error:&err];
    
    if (err)
        NSLog(@"REGEX ERR: %@", err.localizedDescription);
    
    if (regex) {
        NSTextCheckingResult *match = [regex firstMatchInString:stringContainingHex options:0 range:NSMakeRange(0, stringContainingHex.length)];
        
        if (!match) return parsedColor;
        
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
        
        // Make UIColor from hex
        parsedColor = colorFromHex(hexString);
        parsedColor = [parsedColor colorWithAlphaComponent:alphaValue];
    }
    
    return parsedColor;
}

UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback) {
    PFColor *fallbackColor = [PFColor colorWithHex:colorStringFallback];
    NSCAssert(fallbackColor != nil, @"Fallback color must not be nil.");
    PFColor *color = [PFColor colorWithHex:colorStringFromPrefs fallbackColor:fallbackColor];
    return color.UIColor;
}
