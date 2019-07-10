//
//  PFColorPickerBaseViewController.h
//  libcolorpicker_dynamic
//
//  Created by Bailey Seymour on 6/26/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PFColor;

@interface PFColorPickerBaseViewController : UIViewController

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, assign) BOOL showAlpha;
@property (nonatomic, strong, readonly) PFColor *color;
- (void)setPrimaryColor:(UIColor *)primary;
- (void)presentPasteHexStringQuestion:(NSString *)pasteboard;

@end

NS_ASSUME_NONNULL_END
