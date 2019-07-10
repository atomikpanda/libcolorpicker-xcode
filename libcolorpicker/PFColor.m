//
//  PFColor.m
//  libcolorpicker
//
//  Created by Bailey Seymour on 7/9/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "PFColor.h"
#import <UIKit/UIKit.h>

struct PFColorModelRGBA {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};

typedef struct PFColorModelRGBA PFColorModelRGBA;

struct PFColorModelRGB {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
};

typedef struct PFColorModelRGB PFColorModelRGB;

struct PFColorModelHSBA {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
};

typedef struct PFColorModelHSBA PFColorModelHSBA;

struct PFColorModelHSB {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
};

typedef struct PFColorModelHSB PFColorModelHSB;

double fmax3(double x, double y, double z) {
    double result;
    result = fmax(x, y);
    result = fmax(result, z);
    return result;
}

double fmin3(double x, double y, double z) {
    double result;
    result = fmin(x, y);
    result = fmin(result, z);
    return result;
}

@implementation PFColor

#pragma mark Constructors

- (instancetype)init {
    if ((self = [super init])) {
        self.red = 1.0f;
        self.green = 1.0f;
        self.blue = 1.0f;
        self.alpha = 1.0f;
    }
    
    return self;
}

// RGB

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

// Hex

- (nullable instancetype)initWithHex:(NSString *)hexString {
    if ((self = [self init])) {
        if ([self setValuesFromHex:hexString]) {
            return self;
        }
    }
    return nil;
}

- (nullable instancetype)initWithHex:(NSString *)hexString fallbackColor:(nonnull PFColor *)fallback {
    if ((self = [self init])) {
        BOOL valid = [self setValuesFromHex:hexString];
        if (!valid) {
            // Use fallback if valid
            if ([self setValuesFromHex:fallback.hexString]) {
                return self;
            }
        } else {
            // Use hex color
            return self;
        }
    }
    return nil;
}

// UIColor

- (instancetype)initWithUIColor:(UIColor *)color {
    if ((self = [self init])) {
        [self setValuesFromUIColor:color];
    }
    return self;
}

#pragma mark Factory methods

// RGB

+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [[self alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [[self alloc] initWithRed:red green:green blue:blue];
}

// Hex

+ (nullable instancetype)colorWithHex:(NSString *)hexString {
    return [[self alloc] initWithHex:hexString];
}

+ (nullable instancetype)colorWithHex:(NSString *)hexString fallbackColor:(nonnull PFColor *)fallback {
    return [[self alloc] initWithHex:hexString fallbackColor:fallback];
}

// UIColor

+ (instancetype)colorWithUIColor:(UIColor *)color {
    return [[self alloc] initWithUIColor:color];
}


#pragma mark Properties

- (void)setRed:(CGFloat)red {
    _red = [PFColor limitColorValue:red];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(valueDidChange:)]) {
        [self.delegate valueDidChange:self];
    }
}

- (void)setGreen:(CGFloat)green {
    _green = [PFColor limitColorValue:green];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(valueDidChange:)]) {
        [self.delegate valueDidChange:self];
    }
}

- (void)setBlue:(CGFloat)blue {
    _blue = [PFColor limitColorValue:blue];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(valueDidChange:)]) {
        [self.delegate valueDidChange:self];
    }
}

- (void)setAlpha:(CGFloat)alpha {
    _alpha = [PFColor limitColorValue:alpha];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(valueDidChange:)]) {
        [self.delegate valueDidChange:self];
    }
}

- (void)setRGB:(PFColorModelRGB)rgb {
    self.red = rgb.red;
    self.green = rgb.green;
    self.blue = rgb.blue;
}

- (void)setHSB:(PFColorModelHSB)hsb {
    [self setRGB:[self hsbToRGB:hsb]];
}

- (CGFloat)convert:(PFColorModelHSB)hsb toRGB:(CGFloat)n {
    CGFloat hue = hsb.hue * 360.0f;
    CGFloat saturation = hsb.saturation;
    CGFloat brightness = hsb.brightness;
    CGFloat k = ((int)(n+(hue/60)) % 6);
    return brightness-brightness*saturation*fmax(fmin3(k, 4-k, 1), 0);
}

- (PFColorModelRGB)hsbToRGB:(PFColorModelHSB)hsb {
    PFColorModelRGB result;
    result.red = [self convert:hsb toRGB:5];
    result.green = [self convert:hsb toRGB:3];
    result.blue = [self convert:hsb toRGB:1];
    return result;
}

- (void)setHue:(CGFloat)hue {
    PFColorModelHSB hsb = {hue, self.saturation, self.brightness};
    [self setHSB:hsb];
}

- (void)setSaturation:(CGFloat)saturation {
    PFColorModelHSB hsb = {self.hue, saturation, self.brightness};
    [self setHSB:hsb];
}

- (void)setBrightness:(CGFloat)brightness {
    PFColorModelHSB hsb = {self.hue, self.saturation, brightness};
    [self setHSB:hsb];
}

- (CGFloat)hue {
    
    CGFloat hue, min, max, chroma;
    [self rgbMin:&min max:&max chroma:&chroma];
    
    if (_red == max) {
        hue = (_green - _blue) / chroma;
    } else if (_green == max) {
        hue = 2 + (_blue - _red) / chroma;
    } else {
        hue = 4 + (_red - _green) / chroma;
    }
    
    hue *= 60;
    if (hue < 0)
        hue += 360;
    
    return hue / 360.0f;
}

- (CGFloat)saturation {
    
    CGFloat saturation, min, max, chroma;
    [self rgbMin:&min max:&max chroma:&chroma];
    
    if (max != 0)
        saturation = chroma / max;
    else
        saturation = 0.0f;
    
    return saturation;
}

- (CGFloat)brightness {
    
    CGFloat min, max, chroma;
    [self rgbMin:&min max:&max chroma:&chroma];
    return max;
}

#pragma mark Computed properties

- (NSString *)hexString {
    return [[NSString stringWithFormat:@"#%02X%02X%02X",
             (int)(self.red * 255), (int)(self.green * 255), (int)(self.blue * 255)]
            uppercaseString];
}

- (UIColor *)UIColor {
    return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}

- (CGColorRef)CGColor {
    return self.UIColor.CGColor;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n<PFColor: %@\n\tr: %g, g: %g, b: %g\n\th: %g, s: %g, b: %g\n\talpha: %g>",
            self.hexString,
            self.red, self.green, self.blue,
            self.hue, self.saturation, self.brightness, self.alpha];
}

- (BOOL)setValuesFromHex:(NSString *)stringContainingHex {
    
    if (!stringContainingHex) return NO;
    
    CGFloat r, g, b, a;
    BOOL success = [PFColor sanitizeAndParseHex:stringContainingHex red:&r green:&g blue:&b alpha:&a];
    
    if (!success) return NO;
    
    self.red = r;
    self.green = g;
    self.blue = b;
    self.alpha = a;
    return YES;
}

- (void)setValuesFromUIColor:(UIColor *)color {
    
    if (!color) return;
    
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    self.red = r;
    self.green = g;
    self.blue = b;
    self.alpha = a;
}

- (void)rgbMin:(CGFloat *)min max:(CGFloat *)max chroma:(CGFloat *)chroma {
    *max = fmax(_red, _green);
    *max = fmax(*max, _blue);
    
    *min = fmin(_red, _green);
    *min = fmin(*min, _blue);
    
    *chroma = *max-*min;
}

#pragma mark Class util methods

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

+ (BOOL)sanitizeAndParseHex:(NSString *)stringContainingHex red:(CGFloat *)outRed green:(CGFloat *)outGreen blue:(CGFloat *)outBlue alpha:(CGFloat *)outAlpha {
    
    if (!stringContainingHex) return NO;
    
    NSError *err;
    // ((?:#|^)((?:(?:[A-Fa-f]|\d){3}){1,2})(?::((?:\d|\.)+))?)
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((?:#|^)((?:(?:[A-Fa-f]|\\d){3}){1,2})(?::((?:\\d|\\.)+))?)" options:0 error:&err];
    
    if (err) {
        NSLog(@"REGEX ERR: %@", err.localizedDescription);
        return NO;
    }
    
    if (regex) {
        NSTextCheckingResult *match = [regex firstMatchInString:stringContainingHex options:0 range:NSMakeRange(0, stringContainingHex.length)];
        
        if (!match) return NO;
        
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
        return YES;
    }
    return NO;
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

@end
