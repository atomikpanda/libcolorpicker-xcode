//
//  PFColor.h
//  libcolorpicker
//
//  Created by Bailey Seymour on 7/9/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN
@class UIColor, PFColor;

@protocol PFColorDelegate <NSObject>

- (void)valueDidChange:(PFColor *)color;

@end

@interface PFColor : NSObject

// Constructors
- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (nullable instancetype)initWithHex:(NSString *)hexString fallbackColor:(PFColor *)fallback;
- (nullable instancetype)initWithHex:(NSString *)hexString;
- (instancetype)initWithUIColor:(UIColor *)color;

// Conveinence
+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (instancetype)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (nullable instancetype)colorWithHex:(NSString *)hexString fallbackColor:(PFColor *)fallback;
+ (nullable instancetype)colorWithHex:(NSString *)hexString;
+ (instancetype)colorWithUIColor:(UIColor *)color;

// Instance methods
- (BOOL)setValuesFromHex:(NSString *)hexString;
- (void)setValuesFromUIColor:(UIColor *)color;

// Properties
@property (nonatomic, assign) CGFloat red;
@property (nonatomic, assign) CGFloat green;
@property (nonatomic, assign) CGFloat blue;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;
@property (nonatomic, weak) id<PFColorDelegate> delegate;

// Readonly
@property (nonatomic, copy, readonly) NSString *hexString;
@property (nonatomic, copy, readonly) UIColor *UIColor;
@property (nonatomic, assign, readonly) CGColorRef CGColor;

@end

NS_ASSUME_NONNULL_END
