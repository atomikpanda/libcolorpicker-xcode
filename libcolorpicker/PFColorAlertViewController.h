#import <UIKit/UIKit.h>

@interface PFColorAlertViewController : UIViewController

@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, assign) BOOL showAlpha;
@property (nonatomic, assign) BOOL isEncapsulatedInAlert;

- (float)topMostSliderLastYCoordinate;
- (void)setPrimaryColor:(UIColor *)primary;
- (UIColor *)getColor;
@end
