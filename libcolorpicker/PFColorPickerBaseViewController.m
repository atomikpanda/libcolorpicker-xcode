//
//  PFColorPickerBaseViewController.m
//  libcolorpicker_dynamic
//
//  Created by Bailey Seymour on 6/26/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import "PFColorPickerBaseViewController.h"
#import "PFHaloHueView.h"
#import "PFColorLitePreviewView.h"
#import "PFColorLiteSlider.h"
#import "UIColor+PFColor.h"
#import <PureLayout/PureLayout.h>

@interface PFColorPickerBaseViewController () <PFHaloHueViewDelegate> {
    PFHaloHueView *_haloView;
    UIButton *_hexButton;
    PFColorLiteSlider *_brightnessSlider;
    PFColorLiteSlider *_saturationSlider;
    PFColorLiteSlider *_alphaSlider;
    UIStackView *_sliderContainerStackView;
    PFColorLitePreviewView *_litePreviewView;
}
@property (nonatomic, assign) BOOL didSetupConstraints;
@end

@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(long long)style;
@end

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)fitsSuperview settings:(_UIBackdropViewSettings *)settings;
@end


@implementation PFColorPickerBaseViewController
@synthesize didSetupConstraints=_didSetupConstraints, startColor=_startColor, showAlpha=_showAlpha,
blurView=_blurView;

- (void)loadView {
    [super loadView];
    
    // Add subviews
    
    // Blur view
    if (NSClassFromString(@"_UIBackdropView")) {
        // TODO: replace with UIVisualEffectView if available
        _UIBackdropViewSettings *backSettings = [NSClassFromString(@"_UIBackdropViewSettings") settingsForStyle:2010];
        _blurView = [[NSClassFromString(@"_UIBackdropView") alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:backSettings];
    } else {
        _blurView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
    }
    
    [_blurView configureForAutoLayout];
    [self.view addSubview:_blurView];
    
    // Halo view
    _haloView = [[PFHaloHueView alloc] initWithFrame:CGRectZero minValue:0 maxValue:1 value:0 delegate:self];
    _haloView = [_haloView configureForAutoLayout];
    [self.view addSubview:_haloView];
    
    // Sliders
    _sliderContainerStackView = [[UIStackView alloc] initForAutoLayout];
    _sliderContainerStackView.axis = UILayoutConstraintAxisVertical;
    _sliderContainerStackView.distribution = UIStackViewDistributionFill;
    _sliderContainerStackView.spacing = 8.0f;
    
    _saturationSlider = [[PFColorLiteSlider alloc] initWithFrame:CGRectZero color:_startColor style:PFSliderBackgroundStyleSaturation];
    
    _brightnessSlider = [[PFColorLiteSlider alloc] initWithFrame:CGRectZero color:_startColor style:PFSliderBackgroundStyleBrightness];
    
    _alphaSlider = [[PFColorLiteSlider alloc] initWithFrame:CGRectZero color:_startColor style:PFSliderBackgroundStyleAlpha];
    
    [_saturationSlider.slider addTarget:self action:@selector(saturationChanged:) forControlEvents:UIControlEventValueChanged];
    [_brightnessSlider.slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [_alphaSlider.slider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_sliderContainerStackView addArrangedSubview:_saturationSlider];
    [_sliderContainerStackView addArrangedSubview:_brightnessSlider];
    [_sliderContainerStackView addArrangedSubview:_alphaSlider];
    [self.view addSubview:_sliderContainerStackView];
    
    // Preview view
    _litePreviewView = [[PFColorLitePreviewView alloc] initWithFrame:CGRectZero
                                                           mainColor:_startColor
                                                       previousColor:_startColor];
    [self.view addSubview:_litePreviewView];
    
    // Hex button
    _hexButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_hexButton addTarget:self action:@selector(chooseHexColor) forControlEvents:UIControlEventTouchUpInside];
    [_hexButton setTitle:@"#" forState:UIControlStateNormal];
    [self.view addSubview:_hexButton];
    
    // Tell auto layout to update
    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        
        float padding = 32.0f;
        // Update auto layout contraints
        
        // Blur view constraints
        [_blurView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [_blurView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [_blurView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [_blurView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_sliderContainerStackView withOffset:padding];
        
        // Hex button
        [_hexButton autoPinEdgeToSuperviewSafeArea:ALEdgeTop withInset:padding];
        [_hexButton autoPinEdgeToSuperviewSafeArea:ALEdgeRight withInset:padding];
        [_hexButton autoSetDimension:ALDimensionHeight toSize:[_hexButton intrinsicContentSize].height];
        
        // Halo hue view constraints
        [_haloView autoPinEdgeToSuperviewSafeArea:ALEdgeLeft withInset:padding];
        [_haloView autoPinEdgeToSuperviewSafeArea:ALEdgeRight withInset:padding];
        [_haloView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_hexButton];
        [_haloView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:_haloView];
        
        // Slider constraints
        [_sliderContainerStackView autoPinEdgeToSuperviewSafeArea:ALEdgeLeft withInset:padding];
        [_sliderContainerStackView autoPinEdgeToSuperviewSafeArea:ALEdgeRight withInset:padding];
        [_sliderContainerStackView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_haloView withOffset:padding];
        
        // Preview view
        [_litePreviewView autoAlignAxis:ALAxisVertical toSameAxisOfView:_haloView];
        [_litePreviewView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_haloView];
        [_litePreviewView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_haloView withMultiplier:0.4];
        [_litePreviewView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:_haloView withMultiplier:0.4];
        
        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

- (void)chooseHexColor {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hex Color" message:@"Enter a hex color or copy it to your pasteboard." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [UIColor hexFromColor:[self getColor]];
    }];
    
    // Set from hex color
    [alertController addAction:[UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = [alertController textFields].firstObject;
        if (!textField) return;
        
        NSString *userHexString = textField.text;
        if ([userHexString hasPrefix:@"#"] && [UIColor PF_colorWithHex:userHexString])
            [self setPrimaryColor:[UIColor PF_colorWithHex:userHexString]];
    }]];
    
    // Copy to pasteboard
    [alertController addAction:[UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:[self getColor]]];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (float)topMostSliderLastYCoordinate {
    UIView *firstVisibleSlider = !_alphaSlider.hidden ? _alphaSlider : _brightnessSlider;
    return firstVisibleSlider.frame.origin.y + firstVisibleSlider.frame.size.height;
}

- (void)setShowAlpha:(BOOL)showAlpha {
    _showAlpha = showAlpha;
    
    [self loadViewIfNeeded];
    _alphaSlider.hidden = !_showAlpha;
}

- (void)setStartColor:(UIColor *)startColor {
    _startColor = startColor;
    [self loadViewIfNeeded];
    [self setPrimaryColor:_startColor];
}

- (void)setPrimaryColor:(UIColor *)primary {
    [_litePreviewView updateWithColor:primary];
    
    [_saturationSlider updateGraphicsWithColor:primary];
    [_brightnessSlider updateGraphicsWithColor:primary];
    [_alphaSlider updateGraphicsWithColor:primary];
    
    [_haloView setValue:primary.hue];
}

- (UIColor *)getColor {
    return _litePreviewView.mainColor;
}

- (void)hueChanged:(float)hue {
    UIColor *color = [UIColor colorWithHue:hue saturation:_litePreviewView.mainColor.saturation brightness:_litePreviewView.mainColor.brightness alpha:_litePreviewView.mainColor.alpha];
    [_litePreviewView updateWithColor:color];
    [_saturationSlider updateGraphicsWithColor:color hue:hue];
    [_brightnessSlider updateGraphicsWithColor:color hue:hue];
    [_alphaSlider updateGraphicsWithColor:color hue:hue];
}

- (void)saturationChanged:(UISlider *)slider {
    UIColor *color = [UIColor colorWithHue:_litePreviewView.mainColor.hue saturation:slider.value brightness:_litePreviewView.mainColor.brightness alpha:_litePreviewView.mainColor.alpha];
    [_litePreviewView updateWithColor:color];
    [_saturationSlider updateGraphicsWithColor:color];
    [_alphaSlider updateGraphicsWithColor:color];
}

- (void)brightnessChanged:(UISlider *)slider {
    UIColor *color = [UIColor colorWithHue:_litePreviewView.mainColor.hue saturation:_litePreviewView.mainColor.saturation brightness:slider.value alpha:_litePreviewView.mainColor.alpha];
    [_litePreviewView updateWithColor:color];
    [_brightnessSlider updateGraphicsWithColor:color];
    [_alphaSlider updateGraphicsWithColor:color];
}

- (void)alphaChanged:(UISlider *)slider {
    UIColor *color = [UIColor colorWithHue:_litePreviewView.mainColor.hue saturation:_litePreviewView.mainColor.saturation brightness:_litePreviewView.mainColor.brightness alpha:slider.value];
    [_litePreviewView updateWithColor:color];
    [_alphaSlider updateGraphicsWithColor:color];
}

- (void)presentPasteHexStringQuestion:(NSString *)pasteboard {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Detected pasted color" message:@"It seems like your pasteboard consists of a hex color. Would you like to use it?" preferredStyle:UIAlertControllerStyleAlert];
    
    // Set from hex color
    [alertController addAction:[UIAlertAction actionWithTitle:@"Use pasteboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setPrimaryColor:[UIColor PF_colorWithHex:pasteboard]];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
