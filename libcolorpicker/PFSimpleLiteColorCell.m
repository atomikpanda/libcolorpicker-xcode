#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
//#import "libcolorpicker.h"
#import "PSSpecifier.h"
#import "PFColor.h"
#import "CaptainHook.h"
#import <dlfcn.h>
#import "PFColorAlert.h"
#import "PFColor.h"

@interface PFSimpleLiteColorCell : PFLiteColorCell
@end

@interface PFSimpleLiteColorCell()
- (void)openColorAlert;
- (void)setLCPOptions;
- (id)target;
- (SEL)action;
- (id)cellTarget;
- (SEL)cellAction;
@property (nonatomic, retain) NSMutableDictionary *options;
@property (nonatomic, retain) PFColorAlert *alert;
@end

UIColor *LCPParseColorString(NSString * colorStringFromPrefs,  NSString * colorStringFallback);

#define kPostNotification @"PostNotification"
#define kKey @"key"
#define kDefaults @"defaults"
#define kAlpha @"alpha"
#define kFallback @"fallback"

//CHDeclareClass(PFSimpleLiteColorCell);
//CHDeclareClass(PFLiteColorCell);

CHMethod(3, id, PFSimpleLiteColorCell, initWithStyle, long long, arg1, reuseIdentifier, NSString *, arg2, specifier,  PSSpecifier *, arg3) {
    if ((self = CHSuper(3, PFSimpleLiteColorCell, initWithStyle, arg1, reuseIdentifier, arg2, specifier, arg3))) {
        [self setLCPOptions];
    }
    return self;
}

CHMethod(0, void, PFSimpleLiteColorCell, setLCPOptions) {
    self.options = [self.specifier properties][@"libcolorpicker"];
    if (!self.options)
        self.options = [NSMutableDictionary dictionary];
    
    if (!self.options[kPostNotification]) {
        NSString *option = [NSString stringWithFormat:@"%@_%@_libcolorpicker_refreshn",
                            self.options[kDefaults], self.options[kKey]];
        [self.options setObject:option forKey:kPostNotification];
    }
    
    [(PSSpecifier *)self.specifier setProperty:self.options[kPostNotification] forKey:@"NotificationListener"];
}

CHMethod(0, UIColor *, PFSimpleLiteColorCell, previewColor) {
    NSString *plistPath =  [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.options[kDefaults]];
    
    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!prefsDict)
        prefsDict = [NSMutableDictionary dictionary];
    
    return LCPParseColorString([prefsDict objectForKey:self.options[kKey]], self.options[kFallback]); // this color will be used at startup
}

CHMethod(0, void, PFSimpleLiteColorCell, didMoveToSuperview) {
    [self setLCPOptions];
    CHSuper(0, PFSimpleLiteColorCell, didMoveToSuperview);
    
    [self.specifier setTarget:self];
    [self.specifier setButtonAction:@selector(openColorAlert)];
}

CHMethod(0, void, PFSimpleLiteColorCell, openColorAlert) {
    if (!self.options[kDefaults] || !self.options[kKey] || !self.options[kFallback])
        return;
    
    // HBLogDebug(@"Loading with options %@", self.options);
    
    NSString *plistPath =  [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.options[kDefaults]];
    
    NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!prefsDict)
        prefsDict = [NSMutableDictionary dictionary];
    
    UIColor *startColor = LCPParseColorString([prefsDict objectForKey:self.options[kKey]], self.options[kFallback]); // this color will be used at startup
    BOOL showAlpha = self.options[kAlpha] ? [self.options[kAlpha] boolValue] : NO;
    self.alert = [PFColorAlert colorAlertWithStartColor:startColor
                                              showAlpha:showAlpha];
    
    // show alert                               // Show alpha slider? // Code to run after close
    [self.alert displayWithCompletion:^void (UIColor *pickedColor) {
        PFColor *color = [PFColor colorWithUIColor:pickedColor];
        
        [prefsDict setObject:color.preferencesHexValue forKey:self.options[kKey]];
        [prefsDict writeToFile:plistPath atomically:YES];
        
        NSString *notification = self.options[kPostNotification];
        if (notification)
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                                 (CFStringRef)notification,
                                                 (CFStringRef)notification,
                                                 NULL,
                                                 YES);
    }];
}

CHMethod(0, SEL, PFSimpleLiteColorCell, action) {
    return @selector(openColorAlert);
}

CHMethod(0, id, PFSimpleLiteColorCell, target) {
    return self;
}

CHMethod(0, SEL, PFSimpleLiteColorCell, cellAction) {
    return @selector(openColorAlert);
}

CHMethod(0, id, PFSimpleLiteColorCell, cellTarget) {
    return self;
}

//@implementation PFSimpleLiteColorCell
//
//- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
//    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
//
//    [self setLCPOptions];
//
//    return self;
//}
//
//@end
