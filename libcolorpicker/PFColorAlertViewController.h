#import <UIKit/UIKit.h>

@interface PFColorAlertViewController : UIViewController
- (id)initWithViewFrame:(CGRect)frame startColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;
- (float)topMostSliderLastYCoordinate;
- (void)setPrimaryColor:(UIColor *)primary;
- (UIColor *)getColor;
@end
