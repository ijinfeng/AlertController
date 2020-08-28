//
//  PopoAlertContentProtocol.h
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIViewControllerTransitioning.h>

typedef NS_ENUM(NSInteger, PopoAlertAnimation) {
    /// pop like system alert,it is Default style
    PopoAlertAnimationPopAlert,
    /// animation like system sheet
    PopoAlertAnimationSheet,
    PopoAlertAnimationPullDown,
};

NS_ASSUME_NONNULL_BEGIN
@class PopoAlertAction;
@protocol PopoAlertContentProtocol <NSObject>

@required
- (CGRect)frameForViewContent;

@optional
- (instancetype)initWithTitle:(nullable NSString *)title
                      message:(nullable NSString *)message
                      actions:(NSArray <PopoAlertAction *>*)actions;

/// custom Transition
- (void)customAnimateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

/// default 'PopoAlertAnimationPopAlert'.If you need not any animation for alert,you can return animationDuration 0.
- (PopoAlertAnimation)alertAnimation;

/// animation bg color to black 40%(Default).You can custom bg color
- (UIColor *)animationTransitionColor;

/// default is 0.25s
- (NSTimeInterval)animationDuration;
<<<<<<< HEAD

/// is set animate YES, default 0.25
- (NSTimeInterval)setNeedsUpdateFrameAnimationDuration;

/// called when alert show on view
- (void)alertDidShow;

/// called when alert remove from superview
- (void)alertDidDismiss;

=======
>>>>>>> 01fbdfe5a175c31f56212f0947386a4913a0fcf7
@end

NS_ASSUME_NONNULL_END
