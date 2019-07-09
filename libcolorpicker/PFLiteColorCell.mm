

#import "PSTableCell.h"
#import "PSSpecifier.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

#define CHAppName "libcolorpicker"

#import <CaptainHook.h>

@interface PFLiteColorCell : PSTableCell
@property (nonatomic, retain) UIView *colorPreview;
@property (nonatomic, assign) CFNotificationCallback callBack;
- (UIColor *)previewColor;
- (void)updateCellDisplay;
@end

@interface UIColor()
+ (NSString *)hexFromColor:(UIColor *)color;
@end


// Preferences changed notification callback
static void PFLiteColorCellNotifCB(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    PFLiteColorCell *cell = (__bridge PFLiteColorCell *)observer;
    [UIView animateWithDuration:0.45
                         animations:^{
                           [cell updateCellDisplay];
                         }
     completion:^(BOOL finished){}];

}

CHDeclareClass(PSTableCell);
CHDeclareClass(PFLiteColorCell);

CHMethod(0, UIColor *, PFLiteColorCell, previewColor) {
    return [UIColor cyanColor];
}

CHMethod(0, void, PFLiteColorCell, updateCellDisplay) {
    self.colorPreview.backgroundColor = [self previewColor];
    self.detailTextLabel.text = [UIColor hexFromColor:[self previewColor]];
    self.detailTextLabel.alpha = 0.65;
}

CHMethod(0, void, PFLiteColorCell, didMoveToSuperview) {
    CHSuper(0, PFLiteColorCell, didMoveToSuperview);
    NSString *notificationId = [[self specifier] propertyForKey:@"NotificationListener"];
    
    if (notificationId) {
        CFNotificationCenterRemoveEveryObserver (CFNotificationCenterGetDarwinNotifyCenter(), (void *)self);
        
        CFNotificationCenterAddObserver (CFNotificationCenterGetDarwinNotifyCenter(),
                                         (void *)self,
                                         PFLiteColorCellNotifCB,
                                         (CFStringRef)notificationId,
                                         NULL,
                                         CFNotificationSuspensionBehaviorCoalesce
                                         );
    }
    
    self.colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    
    self.colorPreview.tag = 199; //Stop UIColors from overriding the color :P
    self.colorPreview.layer.cornerRadius = self.colorPreview.frame.size.width / 2;
    self.colorPreview.layer.borderWidth = 2;
    self.colorPreview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self setAccessoryView:self.colorPreview];
    [self updateCellDisplay];
}

//CHMethod(0, void, PFLiteColorCell, dealloc) {
//
//    CFNotificationCenterRemoveEveryObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self);
//}

CHPropertyRetainNonatomic(PFLiteColorCell, UIView *, colorPreview, setColorPreview);

CHConstructor {
    dlopen("/System/Library/PrivateFrameworks/Preferences.framework", RTLD_NOW);
    CHLoadLateClass(PSTableCell);
    CHRegisterClass(PFLiteColorCell, PSTableCell);
}

