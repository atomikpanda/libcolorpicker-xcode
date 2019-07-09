//
//  ViewController.m
//  LCPExampleApp
//
//  Created by Bailey Seymour on 6/26/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "ViewController.h"
#import "../libcolorpicker/libcolorpicker.h"
#import "../libcolorpicker/PFColorPickerViewController.h"

@interface ViewController () <PFColorPickerDelegate>
@property (nonatomic, strong) PFColorAlert *alert;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)openColorPickerTapped:(UIButton *)sender {
    NSString *readFromKey = @"someCoolKey"; //  (You want to load from prefs probably)
    NSString *fallbackHex = @"#ff0000";  // (You want to load from prefs probably)
    
    UIColor *startColor = LCPParseColorString(readFromKey, fallbackHex); // this color will be used at startup
    self.alert = [[PFColorAlert alloc] initWithStartColor:[UIColor yellowColor] showAlpha:YES];
    
    // show alert and set completion callback
    [self.alert displayWithCompletion:
     ^void (UIColor *pickedColor) {
         // save pickedColor or do something with it
         NSString *hexString = [UIColor hexFromColor:pickedColor];
         hexString = [hexString stringByAppendingFormat:@":%f", pickedColor.alpha];
         // you probably want to save hexString to your prefs
         // maybe post a notification here if you need to
     }];
}

- (IBAction)presentColorPickerExample:(UIButton *)sender {
    PFColorPickerViewController *controller = [[PFColorPickerViewController alloc] init];
    controller.startColor = [UIColor greenColor];
    controller.showAlpha = YES;
    controller.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)pushColorPickerExample:(UIButton *)sender {
    PFColorPickerViewController *controller = [[PFColorPickerViewController alloc] init];
    controller.startColor = [UIColor greenColor];
    controller.showAlpha = YES;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)colorPicker:(PFColorPickerViewController *)viewController didFinishWithColor:(UIColor *)color {
    self.view.backgroundColor = color;
}

- (void)colorPickerWasCancelled:(PFColorPickerViewController *)viewController {
    NSLog(@"Cancelled");
}

@end
