//
//  PFColorPickerViewController.h
//  libcolorpicker_dynamic
//
//  Created by Bailey Seymour on 6/26/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "PFColorPickerBaseViewController.h"
#import "PFColorPickerDelegate.h"

@interface PFColorPickerViewController : PFColorPickerBaseViewController
@property (nonatomic, retain) id<PFColorPickerDelegate> delegate;
@end
