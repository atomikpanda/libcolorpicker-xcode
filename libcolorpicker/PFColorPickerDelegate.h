//
//  PFColorPickerDelegate.h
//  libcolorpicker
//
//  Created by Bailey Seymour on 6/26/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFColorPickerViewController;
@protocol PFColorPickerDelegate <NSObject>

- (void)colorPicker:(PFColorPickerViewController *)viewController didFinishWithColor:(UIColor *)color;
- (void)colorPickerWasCancelled:(PFColorPickerViewController *)viewController;

@end
