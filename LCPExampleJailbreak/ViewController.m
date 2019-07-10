//
//  ViewController.m
//  LCPExampleJailbreak
//
//  Created by Bailey Seymour on 7/10/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "ViewController.h"
#import "../libcolorpicker/libcolorpicker.h"
#import "../libcolorpicker/PFColor.h"
#import "../libcolorpicker/CaptainHook.h"
#import "../libcolorpicker/PSSpecifier.h"
#import <dlfcn.h>

@interface ViewController ()
@property (nonatomic, strong) PFColorAlert *alert;
@end


CHDeclareClass(PSListItemsController);
CHDeclareClass(ExamplePrefsListController);

@interface ExamplePrefsListController : UIViewController
- (id)specifiers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ExamplePrefsListController *exampleVC = [CHAlloc(ExamplePrefsListController) init];
    [self presentViewController:exampleVC animated:YES completion:nil];
    
    return;
    
    NSString *readFromKey = @"someCoolKey"; //  (You want to load from prefs probably)
    NSString *fallbackHex = @"#ff0000";  // (You want to load from prefs probably)
    
    UIColor *startColor = LCPParseColorString(readFromKey, fallbackHex); // this color will be used at startup
    self.alert = [PFColorAlert colorAlertWithStartColor:startColor showAlpha:YES];
    
    // show alert and set completion callback
    [self.alert displayWithCompletion:
     ^void (UIColor *pickedColor) {
         // save pickedColor or do something with it
         
         NSString *hexString = [PFColor colorWithUIColor:pickedColor].preferencesHexValue;
         NSLog(@"Picked color: %@", hexString);
         // you probably want to save hexString to your prefs
         // maybe post a notification here if you need to
     }];
}


@end








CHMethod(0, id, ExamplePrefsListController, specifiers) {
    
    const SEL kSet = @selector(setPreferenceValue:specifier:);
    const SEL kGet = @selector(readPreferenceValue:);
    NSMutableArray *_specifiers = CHIvar(self, _specifiers, __strong NSMutableArray *);
    
    if (_specifiers != nil) return _specifiers;
    
    _specifiers = [[NSMutableArray new] retain];
    
    [_specifiers addObject:[objc_getClass("PSSpecifier") groupSpecifierWithName:@"LCP Example"]];
    
    PSSpecifier *chooseCell = [objc_getClass("PSSpecifier") preferenceSpecifierNamed:@"My Color"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:nil
                                                               cell:PSLinkCell
                                                               edit:nil];
    
    
    [chooseCell setProperty:objc_getClass("PFSimpleLiteColorCell") forKey:@"cellClass"];
    [chooseCell setProperty:@{@"defaults":@"com.baileyseymour.test",
                              @"key": @"MyColor",
                              @"fallback": @"#ff00ff",
                              @"alpha": @YES
                              } forKey:@"libcolorpicker"];
    
    PSSpecifier *albumArtSpec = [objc_getClass("PSSpecifier") preferenceSpecifierNamed:@"Album Art Color for NC|CC|HUD"
                                                               target:self
                                                                  set:nil
                                                                  get:nil
                                                               detail:nil
                                                                 cell:PSSwitchCell
                                                                 edit:nil];
    [_specifiers addObject:albumArtSpec];
    
//    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
//    NSLog(@"BUNDLE: %@", settingsBundle);
//    [chooseCell setProperty:settingsBundle forKey:@"lazy-bundle"];
    //[chooseCell setAction:@selector(lazyLoadBundle:)];
    
    //chooseCell.buttonAction = @selector(chooseColor:);
    //[_specifiers addObject:chooseCell];
    return _specifiers;
}

CHConstructor {
    dlopen("/System/Library/PrivateFrameworks/Preferences.framework/Preferences", RTLD_NOW);
    CHLoadLateClass(PSListItemsController);
    CHRegisterClass(ExamplePrefsListController, PSListItemsController) {
        CHHook(0, ExamplePrefsListController, specifiers);
        CHAddIvar(CHClass(ExamplePrefsListController), _specifiers, __strong NSMutableArray *);
    }
}
