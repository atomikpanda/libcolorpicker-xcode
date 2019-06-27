#import <UIKit/UIKit.h>

@interface PFColorAlertViewController : UIViewController

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, assign) BOOL showAlpha;

- (float)topMostSliderLastYCoordinate;
- (void)setPrimaryColor:(UIColor *)primary;
- (UIColor *)getColor;
@end
