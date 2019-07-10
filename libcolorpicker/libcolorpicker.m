#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PFColor.h"

UIColor *colorFromHex(NSString *hexString);
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);
UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback);

UIColor *colorFromHex(NSString *hexString) {
    return [PFColor colorWithHex:hexString].UIColor;
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

UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback) {
    PFColor *fallbackColor = [PFColor colorWithHex:colorStringFallback];
    NSCAssert(fallbackColor != nil, @"Fallback color must not be nil/invalid.");
    PFColor *color = [PFColor colorWithHex:colorStringFromPrefs fallbackColor:fallbackColor];
    return color.UIColor;
}
