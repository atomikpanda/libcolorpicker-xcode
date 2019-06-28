#import "PFColorAlert.h"
#import "PFColorAlertViewController.h"
#import "UIColor+PFColor.h"
#import <objc/runtime.h>
#import <PureLayout/PureLayout.h>


@interface PFColorAlert()
@property (nonatomic, retain) UIWindow *darkeningWindow;
@property (nonatomic, retain) PFColorAlertViewController *mainViewController;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, copy) void (^completionBlock)(UIColor *pickedColor);
@end


@implementation PFColorAlert

+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    return [[PFColorAlert alloc] initWithStartColor:startColor showAlpha:showAlpha];
}

- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    self = [super init];

    self.isOpen = NO;

    self.darkeningWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.darkeningWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

    CGRect winFrame = [UIScreen mainScreen].bounds;

    float winWidthCalc = winFrame.size.width * 0.09f;
    float winHeightCalc = winFrame.size.height * 0.09f;

    winFrame.origin.x = winWidthCalc / 2;
    winFrame.origin.y = winHeightCalc / 2;

    winFrame.size.width = winFrame.size.width - winWidthCalc;
    winFrame.size.height = winFrame.size.height - winHeightCalc;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat topPadding = window.safeAreaInsets.top;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        CGFloat leftPadding = window.safeAreaInsets.left;
        CGFloat rightPadding = window.safeAreaInsets.right;
        winFrame.size.height -= topPadding;
        winFrame.size.height -= bottomPadding;
        winFrame.size.width -= leftPadding;
        winFrame.size.width -= rightPadding;
    }
    
    self.popWindow = [[UIWindow alloc] initWithFrame:winFrame];
    self.popWindow.layer.masksToBounds = true;
    self.popWindow.layer.cornerRadius = 15;

    self.mainViewController = [[PFColorAlertViewController alloc] init];
    self.mainViewController.startColor = startColor;
    self.mainViewController.showAlpha = showAlpha;

    self.darkeningWindow.hidden = NO;
    self.darkeningWindow.alpha = 0.0f;
    [self.darkeningWindow makeKeyAndVisible];

    self.popWindow.rootViewController = self.mainViewController;
#ifndef DEBUG
    self.darkeningWindow.windowLevel = UIWindowLevelAlert - 2;
    self.popWindow.windowLevel = UIWindowLevelAlert - 1;
#endif
    self.popWindow.backgroundColor = UIColor.clearColor;
    self.popWindow.hidden = NO;
    self.popWindow.alpha = 0.0f;

    [self makeViewDynamic:self.popWindow];
    CGRect popWindowFrame = self.popWindow.frame;
    popWindowFrame.origin.y = ([UIScreen mainScreen].bounds.size.height - popWindowFrame.size.height) / 2;

    self.popWindow.frame = popWindowFrame;

    return self;
}

- (void)makeViewDynamic:(UIView *)view {
    CGRect dynamicFrame = view.frame;
//    dynamicFrame.size.height = [self.mainViewController topMostSliderLastYCoordinate] +
//                               self.mainViewController.view.frame.size.width / 6;

    dynamicFrame.size = self.mainViewController.view.bounds.size;
    view.frame = dynamicFrame;
   
}

- (void)displayWithCompletion:(void (^)(UIColor *pickedColor))completionBlock {
    if (self.isOpen)
        return;

    self.completionBlock = completionBlock;

    [self.popWindow makeKeyAndVisible];

    [UIView animateWithDuration:0.3f animations:^{
        self.darkeningWindow.alpha = 1.0f;
        self.popWindow.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.isOpen = YES;

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        self.darkeningWindow.userInteractionEnabled = YES;
        [self.darkeningWindow addGestureRecognizer:tapGesture];

        NSString *pasteboard = [UIPasteboard generalPasteboard].string;
        if ([pasteboard isEqualToString:[[self.mainViewController getColor] hexFromColor]])
            return;
        
        NSRange range = [pasteboard rangeOfString:@"^#(?:[0-9a-fA-F]{3}){1,2}$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound)
            [self.mainViewController presentPasteHexStringQuestion:pasteboard];
    }];
}

- (void)showWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha completion:(void (^)(UIColor *pickedColor))completionBlock {
    
    // FIXME: replace with UIAlertController
    UIAlertView *deprecated = [[UIAlertView alloc] initWithTitle:@"libcolorpicker" message:@"Hey! It appears like this preference bundle is trying to use deprecated methods to invoke the color picker and requires an update. Please inform the dev of this tweak about it."
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [deprecated show];
}

- (void)close {
    if (!self.isOpen)
        return;

    [UIView animateWithDuration:0.3f animations:^{
        self.darkeningWindow.alpha = 0.0f;
        self.popWindow.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (self.completionBlock)
            self.completionBlock([self.mainViewController getColor]);

        self.popWindow.hidden = YES;
        self.isOpen = NO;
    }];
}

@end
