#import "PFColorLiteSlider.h"
#import "UIColor+PFColor.h"
#import <PureLayout/PureLayout.h>

@interface PFColorSliderBackgroundView : UIView
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat hue;
@property (assign) PFSliderBackgroundStyle style;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)color style:(PFSliderBackgroundStyle)s;
@end

@implementation PFColorSliderBackgroundView
@synthesize color=_color, hue=_hue;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)col style:(PFSliderBackgroundStyle)s {
    self = [super initWithFrame:frame];
    self.color = col;
    self.style = s;
    self.backgroundColor = [UIColor clearColor];

    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.hue = color.hue;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    for (int x = 0; x < rect.size.width; x++) {
        float percent = 100 - (((rect.size.width - x) / rect.size.width) * 100.f);

        if (self.style == PFSliderBackgroundStyleSaturation)
            [[UIColor colorWithHue:self.hue saturation:(percent / 100) brightness:1 alpha:1] setFill];
        else if (self.style == PFSliderBackgroundStyleBrightness)
            [[UIColor colorWithHue:self.hue saturation:1 brightness:(percent / 100) alpha:1] setFill];
        else if (self.style == PFSliderBackgroundStyleAlpha)
            [[UIColor colorWithHue:self.hue saturation:self.color.saturation brightness:self.color.brightness alpha:(percent / 100)] setFill];

        CGContextFillRect(context, CGRectMake(x, 0, 1, rect.size.height));
    }
}

@end

@interface PFColorLiteSlider ()
@property (nonatomic, retain) PFColorSliderBackgroundView *backgroundView;
@property (assign) PFSliderBackgroundStyle style;
@property (nonatomic, assign) BOOL didSetupConstraints;
@end

@implementation PFColorLiteSlider
@synthesize backgroundView;
@synthesize slider;
@synthesize didSetupConstraints;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)c style:(PFSliderBackgroundStyle)s {
    self = [super initWithFrame:frame];

    self.style = s;

    self.slider = [[UISlider alloc] initForAutoLayout];
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 1.0f;

    self.backgroundView = [[PFColorSliderBackgroundView alloc] initWithFrame:frame color:c style:s];

    [self addSubview:self.backgroundView];
    [self addSubview:self.slider];

    [self updateGraphicsWithColor:c];

    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        [self.backgroundView autoPinEdgesToSuperviewMarginsWithInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [self.slider autoPinEdgesToSuperviewEdges];
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)updateGraphicsWithColor:(UIColor *)color {
    [self updateGraphicsWithColor:color hue:color.hue];
}

- (void)updateGraphicsWithColor:(UIColor *)color hue:(CGFloat)hue {
    // The hue parameter is used since UIColor defaults the hue to 0 if there is no saturation
    
    if (self.style == PFSliderBackgroundStyleSaturation)
        [self.slider setThumbImage:[self thumbImageWithColor:[UIColor colorWithHue:hue saturation:color.saturation brightness:1 alpha:1]] forState:UIControlStateNormal];
    else if (self.style == PFSliderBackgroundStyleBrightness)
        [self.slider setThumbImage:[self thumbImageWithColor:[UIColor colorWithHue:hue saturation:1 brightness:color.brightness alpha:1]] forState:UIControlStateNormal];
    else if (self.style == PFSliderBackgroundStyleAlpha)
        [self.slider setThumbImage:[self thumbImageWithColor:[UIColor colorWithHue:hue saturation:color.saturation brightness:color.brightness alpha:color.alpha]] forState:UIControlStateNormal];

    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = [UIColor clearColor];

    self.backgroundView.color = color;
    self.backgroundView.hue = hue;
    [self.backgroundView setNeedsDisplay];

    if (self.style == PFSliderBackgroundStyleSaturation)
        self.slider.value = color.saturation;
    else if (self.style == PFSliderBackgroundStyleBrightness)
        self.slider.value = color.brightness;
    else if (self.style == PFSliderBackgroundStyleAlpha)
        self.slider.value = color.alpha;
}

- (UIImage *)thumbImageWithColor:(UIColor *)color {
    CGFloat size = 28.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, size, size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 6);

    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.3);

    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);

    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3 - 3, 0, 2 * M_PI, 1);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathEOFill);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
