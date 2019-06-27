//
//  PFColorPickerViewController.m
//  libcolorpicker_dynamic
//
//  Created by Bailey Seymour on 6/26/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "PFColorPickerViewController.h"

@interface PFColorPickerViewController ()

@end

@implementation PFColorPickerViewController
@synthesize delegate=_delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.blurView.hidden = YES;
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
}

- (void)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneTapped:(id)sender {
    if (_delegate) {
        [_delegate colorPicker:self didFinishWithColor:[self getColor]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
