#import  <UIKit/UIKit.h>

#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif

UIColor * _Nonnull LCPParseColorString(NSString * _Nullable colorStringFromPrefs,  NSString * _Nonnull colorStringFallback);

__attribute__((deprecated))
UIColor * _Nonnull colorFromDefaultsWithKey(NSString * _Nonnull defaults, NSString * _Nonnull key, NSString * _Nonnull fallback);

#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PFColorAlert : NSObject
+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;
- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;
- (void)displayWithCompletion:(void (^)(UIColor *pickedColor))fcompletionBlock;
- (void)close;
@end

NS_ASSUME_NONNULL_END

// NOTE: might want to remove this if check later
#ifdef JAILBREAK
@interface PFLiteColorCell : UITableViewCell
- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(id)specifier;
- (UIColor *)previewColor; // this will be used for the circle preview view. override in a subclass
- (id)specifier;
- (void)updateCellDisplay;
@end

@interface PFSimpleLiteColorCell : PFLiteColorCell
@end
#endif
