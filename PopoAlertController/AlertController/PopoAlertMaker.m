//
//  PopoAlertMaker.m
//  YunJiBuyer
//
//  Created by JinFeng on 2019/6/3.
//  Copyright © 2019 浙江集商优选电子商务有限公司. All rights reserved.
//

#import "PopoAlertMaker.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static const float kPresentDelay = 0.3;
static const void *kSetNeedsUpdateFrameKey = &kSetNeedsUpdateFrameKey;

typedef NS_ENUM(int, PopoAlertControllerStyle) {
    PopoAlertControllerStyleAlert,
    PopoAlertControllerStyleSheet,
    PopoAlertControllerStyleCustom,
};

#pragma mark - PresentTranstion

@interface PopoPresentTransition : UIPresentationController<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL dismissTapOnTemp;

@property (nonatomic, assign) PopoAlertAnimation animationStyle;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(nullable UIViewController *)presentingViewController
                                          style:(PopoAlertControllerStyle)style;

@end

@interface PopoPresentTransition ()
@property (nonatomic, assign) PopoAlertControllerStyle style;
@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation PopoPresentTransition

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController style:(PopoAlertControllerStyle)style {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _style = style;
        _dismissTapOnTemp = NO;
        _animationStyle = PopoAlertAnimationPopAlert;
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)presentationTransitionWillBegin {
    UIViewController *customAlert = self.presentedViewController;
    UIColor *backgroundColor = [UIColor blackColor];
    if ([customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)]
        && [customAlert respondsToSelector:@selector(animationTransitionColor)]) {
        backgroundColor = [(id<PopoAlertContentProtocol>)customAlert animationTransitionColor];
    }
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = backgroundColor;
    self.backgroundView.alpha = 0;
    [self.containerView addSubview:self.backgroundView];
    
    if (self.dismissTapOnTemp) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionForTapOnTemp)];
        [self.backgroundView addGestureRecognizer:tap];
    }
    
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.backgroundView.alpha = 0.4;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([customAlert respondsToSelector:@selector(alertDidShow)]) {
            [((id<PopoAlertContentProtocol>)customAlert) alertDidShow];
        }
    }];
}

- (void)actionForTapOnTemp {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dismissalTransitionWillBegin {
    UIViewController *customAlert = self.presentedViewController;
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.backgroundView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([customAlert respondsToSelector:@selector(alertDidShow)]) {
            [((id<PopoAlertContentProtocol>)customAlert) alertDidShow];
        }
    }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

- (void)containerViewDidLayoutSubviews {
    UIViewController *toVC = self.presentedViewController;
    if ([toVC conformsToProtocol:@protocol(PopoAlertContentProtocol)]
        && [toVC respondsToSelector:@selector(frameForViewContent)]) {
        CGRect rect = [(id<PopoAlertContentProtocol>)toVC frameForViewContent];
        BOOL animate = [objc_getAssociatedObject(toVC, kSetNeedsUpdateFrameKey) boolValue];
        NSTimeInterval duration = 0;
        if (animate) {
            if ([toVC conformsToProtocol:@protocol(PopoAlertContentProtocol)]
                && [toVC respondsToSelector:@selector(setNeedsUpdateFrameAnimationDuration)]) {
                duration = [(id<PopoAlertContentProtocol>)toVC setNeedsUpdateFrameAnimationDuration];
            } else {
                duration = 0.25;
            }
        }
        [UIView animateWithDuration:duration animations:^{
            toVC.view.frame = rect;
        }];
        objc_setAssociatedObject(self, kSetNeedsUpdateFrameKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (UIPresentationController* )presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BOOL presenting = fromVC == self.presentingViewController;
    UIViewController *alertVC = presenting ? toVC : fromVC;
    if ([alertVC respondsToSelector:@selector(animationDuration)]) {
        return [(id<PopoAlertContentProtocol>)alertVC animationDuration];
    }
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BOOL presenting = fromVC == self.presentingViewController;
    UIViewController *alertVC = presenting ? toVC : fromVC;
    // custom animation
    if ([alertVC conformsToProtocol:@protocol(PopoAlertContentProtocol)]
        && [alertVC respondsToSelector:@selector(customAnimateTransition:)]) {
        [(id<PopoAlertContentProtocol>)alertVC customAnimateTransition:transitionContext];
        return;
    }
    
    // system animation
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    // begin animation
    CGRect finalFrame = CGRectZero, initialFrame = CGRectZero;
    PopoAlertAnimation animation = self.animationStyle;
    if ([alertVC conformsToProtocol:@protocol(PopoAlertContentProtocol)]) {
        if ([alertVC respondsToSelector:@selector(alertAnimation)]) {
            animation = [(id<PopoAlertContentProtocol>)alertVC alertAnimation];
        }
    }
    
    if ([alertVC conformsToProtocol:@protocol(PopoAlertContentProtocol)]) {
        if ([alertVC respondsToSelector:@selector(frameForViewContent)]) {
            finalFrame = [(id<PopoAlertContentProtocol>)alertVC frameForViewContent];
        }
    }
    
    if (animation == PopoAlertAnimationPopAlert) {
        if (presenting) {
            toView.alpha = 0;
            toView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            CGRect rect = finalFrame;
            initialFrame = rect;
        } else {
            initialFrame = finalFrame;
        }
    } else if (animation == PopoAlertAnimationSheet) {
        CGRect rect = finalFrame;
        rect.origin.y = rect.origin.y + finalFrame.size.height;
        initialFrame = rect;
    } else if (animation == PopoAlertAnimationPullDown) {
        CGRect rect = finalFrame;
        rect.origin.y = rect.origin.y - finalFrame.size.height;
        initialFrame = rect;
    }
    
    if (presenting) {
        toView.frame = initialFrame;
        [containerView addSubview:toView];
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (presenting) {
            toView.frame = finalFrame;
            toView.alpha = 1;
            toView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } else {
            fromView.frame = initialFrame;
            fromView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        if (wasCancelled) {
            [toView removeFromSuperview];
        }
        [transitionContext completeTransition:!wasCancelled];
    }];
}

@end

#pragma mark - View Transition

static char *kCustomAlertBindViewTransitionKey = "kCustomAlertBindViewTransitionKey";

@interface PopoAlertViewTransition : NSObject

- (instancetype)initWithCustomAlertView:(UIView *)customAlert onView:(UIView *)onView;

@property (nonatomic, assign) BOOL dismissTapOnTemp;

@property (nonatomic, assign) PopoAlertAnimation animationStyle;

- (void)show;

- (void)dismiss;

- (void)setHidden:(BOOL)hidden;

- (void)setNeedsUpdateFrameWithAnimate:(BOOL)animate;

@end

@interface PopoAlertViewTransition ()

@property (nonatomic, weak) UIView *customAlert;

@property (nonatomic, weak) UIView *onView;

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation PopoAlertViewTransition

- (instancetype)initWithCustomAlertView:(UIView *)customAlert onView:(UIView *)onView {
    self = [super init];
    if (self) {
        _customAlert = customAlert;
        _onView = onView;
    }
    return self;
}

- (void)show {
    if (!self.customAlert) {
        return;
    }
    objc_setAssociatedObject(self.customAlert, kCustomAlertBindViewTransitionKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIControl *backgroundView = [[UIControl alloc] init];
    backgroundView.userInteractionEnabled = YES;
    self.backgroundView = backgroundView;
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.frame = self.onView.bounds;
    [self.onView addSubview:backgroundView];
    [backgroundView addSubview:self.customAlert];
    
    if (self.dismissTapOnTemp) {
        [backgroundView addTarget:self action:@selector(actionForTapOnTemp:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGRect finalRect = CGRectZero;
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(frameForViewContent)]) {
        finalRect = [(id<PopoAlertContentProtocol>)self.customAlert frameForViewContent];
    }
    
    NSTimeInterval duration = 0.25;
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(animationDuration)]) {
        duration = [(id<PopoAlertContentProtocol>)self.customAlert animationDuration];
    }
    
    UIColor *finalBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(animationTransitionColor)]) {
        finalBackgroundColor = [(id<PopoAlertContentProtocol>)self.customAlert animationTransitionColor];
    }
    
    PopoAlertAnimation animation = self.animationStyle;
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(alertAnimation)]) {
        animation = [(id<PopoAlertContentProtocol>)self.customAlert alertAnimation];
    }

    CGRect beginRect = finalRect;
    if (animation == PopoAlertAnimationSheet) {
        beginRect.origin.y = CGRectGetHeight(self.backgroundView.frame);
    } else if (animation == PopoAlertAnimationPullDown) {
        beginRect.origin.y = CGRectGetMinY(self.backgroundView.frame) - CGRectGetHeight(finalRect);
    }
    self.customAlert.frame = beginRect;
    if (animation == PopoAlertAnimationPopAlert) {
        self.customAlert.alpha = 0;
        self.customAlert.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.backgroundColor = finalBackgroundColor;
        self.customAlert.alpha = 1;
        self.customAlert.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.customAlert.frame = finalRect;
    } completion:^(BOOL finished) {
        if ([self.customAlert respondsToSelector:@selector(alertDidShow)]) {
            [((id<PopoAlertContentProtocol>)self.customAlert) alertDidShow];
        }
    }];
}

- (void)dismiss {
    CGRect finalRect = CGRectZero;
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(frameForViewContent)]) {
        finalRect = [(id<PopoAlertContentProtocol>)self.customAlert frameForViewContent];
    }
    
    NSTimeInterval duration = 0.25;
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(animationDuration)]) {
        duration = [(id<PopoAlertContentProtocol>)self.customAlert animationDuration];
    }
    
    PopoAlertAnimation animation = self.animationStyle;
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(alertAnimation)]) {
        animation = [(id<PopoAlertContentProtocol>)self.customAlert alertAnimation];
    }

    if (animation == PopoAlertAnimationSheet) {
        finalRect.origin.y += finalRect.size.height;
    } else if (animation == PopoAlertAnimationPullDown) {
        finalRect.origin.y -= finalRect.size.height;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.customAlert.frame = finalRect;
        if (animation == PopoAlertAnimationPopAlert) {
            self.customAlert.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self.customAlert removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        if ([self.customAlert respondsToSelector:@selector(alertDidDismiss)]) {
            [((id<PopoAlertContentProtocol>)self.customAlert) alertDidDismiss];
        }
    }];
}

- (void)setHidden:(BOOL)hidden {
    self.backgroundView.hidden = hidden;
}

- (void)actionForTapOnTemp:(UIControl *)control {
    [self dismiss];
}

- (void)setNeedsUpdateFrameWithAnimate:(BOOL)animate {
    if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)] && [self.customAlert respondsToSelector:@selector(frameForViewContent)]) {
        CGRect rect = [(id<PopoAlertContentProtocol>)self.customAlert frameForViewContent];
        NSTimeInterval duration = 0;
        if (animate) {
            if ([self.customAlert conformsToProtocol:@protocol(PopoAlertContentProtocol)]
                && [self.customAlert respondsToSelector:@selector(setNeedsUpdateFrameAnimationDuration)]) {
                duration = [(id<PopoAlertContentProtocol>)self.customAlert setNeedsUpdateFrameAnimationDuration];
            } else {
                duration = 0.25;
            }
        }
        [UIView animateWithDuration:duration animations:^{
            self.customAlert.frame = rect;
        }];
    }
}

@end


#pragma mark - Alert Action

@implementation PopoAlertAction

@end


#pragma mark - Alert Maker

@interface PopoAlertMaker ()<UIViewControllerTransitioningDelegate>

- (instancetype)initWithAlertStyle:(PopoAlertControllerStyle)style;
- (instancetype)initWithAlertStyle:(PopoAlertControllerStyle)style
                            custom:(id<PopoAlertContentProtocol>)viewController;

@property (nonatomic, readonly) PopoAlertControllerStyle alertStyle;

@property (nonatomic, strong) NSString *title_;

@property (nonatomic, strong) NSString *message_;

@property (nonatomic) BOOL dimissTapOnTemp_;

@property (nonatomic) PopoAlertAnimation animationStyle_;

@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong) PopoPresentTransition *presentTransition;

@property (nonatomic, strong) PopoAlertViewTransition *viewTransition;

@property (nonatomic, strong) id<PopoAlertContentProtocol> customAlert;

@end

@implementation PopoAlertMaker

- (void)dealloc {
    NSLog(@"PopoAlertMaker dealloc");
}

- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [NSMutableArray array];
    }
    return _actions;
}

+ (PopoAlertMaker *)alert {
    return [[PopoAlertMaker alloc] initWithAlertStyle:PopoAlertControllerStyleAlert];
}

+ (PopoAlertMaker *)sheet {
    return [[PopoAlertMaker alloc] initWithAlertStyle:PopoAlertControllerStyleSheet];
}

- (instancetype)initWithAlertStyle:(PopoAlertControllerStyle)style {
    return [self initWithAlertStyle:style custom:nil];
}

- (instancetype)initWithAlertStyle:(PopoAlertControllerStyle)style custom:(id<PopoAlertContentProtocol>)customAlert {
    if (self = [super init]) {
        _alertStyle = style;
        _customAlert = customAlert;
        _dimissTapOnTemp_ = style == PopoAlertControllerStyleSheet;
        _animationStyle_ = PopoAlertAnimationPopAlert;
    }
    return self;
}

- (PopoAlertMaker * (^)(NSString *))title {
    PopoAlertMaker *(^maker)(NSString *) = ^PopoAlertMaker *(NSString *x) {
        self.title_ = x;
        return self;
    };
    return maker;
}

- (PopoAlertMaker * (^)(NSString *))message {
    PopoAlertMaker *(^maker)(NSString *) = ^PopoAlertMaker *(NSString *x) {
        self.message_ = x;
        return self;
    };
    return maker;
}

- (PopoActionBlock)addDestructiveAction {
    PopoAlertMaker *(^maker)(NSString *, void(^)(void)) = ^PopoAlertMaker *(NSString *x, void(^b)(void)) {
        PopoAlertAction *a = [[PopoAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = PopoAlertActionStyleDestructive;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (PopoActionBlock)addDefaultAction {
    PopoAlertMaker *(^maker)(NSString *, void(^)(void)) = ^PopoAlertMaker *(NSString *x, void(^b)(void)) {
        PopoAlertAction *a = [[PopoAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = PopoAlertActionStyleDefault;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (PopoActionBlock)addForbidAction {
    PopoAlertMaker *(^maker)(NSString *, void(^)(void)) = ^PopoAlertMaker *(NSString *x, void(^b)(void)) {
        PopoAlertAction *a = [[PopoAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = PopoAlertActionStyleForbid;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (PopoActionBlock)addCancelAction {
    PopoAlertMaker *(^maker)(NSString *, void(^)(void)) = ^PopoAlertMaker *(NSString *x, void(^b)(void)) {
        PopoAlertAction *a = [[PopoAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.actionStyle = PopoAlertActionStyleCancel;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (PopoCustomActionBlock)addCustomAction {
    PopoAlertMaker *(^maker)(NSString *,id, void(^)(void)) = ^PopoAlertMaker *(NSString *x, id obj, void(^b)(void)) {
        PopoAlertAction *a = [[PopoAlertAction alloc] init];
        a.title = x;
        a.action = b;
        a.object = obj;
        a.actionStyle = PopoAlertActionStyleCustom;
        [self.actions addObject:a];
        return self;
    };
    return maker;
}

- (void (^)(id _Nonnull))presentFrom {
    void (^maker)(id) = ^(id from) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *x = nil;
            UIView *v = nil;
            if ([from isKindOfClass:[UIViewController class]]) {
                x = (UIViewController *)from;
            } else if ([from isKindOfClass:[UIView class]]) {
                v = (UIView *)from;
            } else {
                return;
            }
            if (self.alertStyle == PopoAlertControllerStyleSheet) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title_ message:self.message_ preferredStyle:UIAlertControllerStyleActionSheet];
                
                for (int i = 0; i < self.actions.count; i++) {
                    PopoAlertAction *a = self.actions[i];
                    UIAlertActionStyle style = UIAlertActionStyleDefault;
                    if (a.actionStyle == PopoAlertActionStyleDestructive) {
                        style = UIAlertActionStyleDestructive;
                    } else if (a.actionStyle == PopoAlertActionStyleDefault) {
                        style = UIAlertActionStyleDefault;
                    } else if (a.actionStyle == PopoAlertActionStyleForbid) {
                        
                    } else {
                        style = UIAlertActionStyleCancel;
                    }
                    UIAlertAction *action = [UIAlertAction actionWithTitle:a.title style:style handler:^(UIAlertAction * _Nonnull action) {
                        if (a.action) {
                            a.action();
                        }
                    }];
                    [alert addAction:action];
                }
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                
                float delay = 0;
                if (x.presentedViewController) {
                    delay = kPresentDelay;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[self getp_vcFrom:x] presentViewController:alert animated:YES completion:nil];
                });
            } else if (self.alertStyle == PopoAlertControllerStyleAlert) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title_ message:self.message_ preferredStyle:UIAlertControllerStyleAlert];
                
                for (int i = 0; i < self.actions.count; i++) {
                    PopoAlertAction *a = self.actions[i];
                    UIAlertActionStyle style = UIAlertActionStyleDefault;
                    if (a.actionStyle == PopoAlertActionStyleDestructive) {
                        style = UIAlertActionStyleDestructive;
                    } else if (a.actionStyle == PopoAlertActionStyleDefault) {
                        style = UIAlertActionStyleDefault;
                    } else if (a.actionStyle == PopoAlertActionStyleForbid) {
                        
                    } else {
                        style = UIAlertActionStyleCancel;
                    }
                    UIAlertAction *action = [UIAlertAction actionWithTitle:a.title style:style handler:^(UIAlertAction * _Nonnull action) {
                        if (a.action) {
                            a.action();
                        }
                    }];
                    [alert addAction:action];
                }
                float delay = 0;
                if (x.presentedViewController) {
                    delay = kPresentDelay;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[self getp_vcFrom:x] presentViewController:alert animated:YES completion:nil];
                });
            } else {
                // custom alert
                if ([self.customAlert isKindOfClass:[UIViewController class]]) {
                    if ([self.customAlert respondsToSelector:@selector(initWithTitle:message:actions:)]) {
                        self.customAlert = [self.customAlert initWithTitle:self.title_ message:self.message_ actions:self.actions.copy];
                    }
                    UIViewController *alert = (UIViewController *)self.customAlert;
                    self.presentTransition = [[PopoPresentTransition alloc] initWithPresentedViewController:alert presentingViewController:x style:self.alertStyle];
                    self.presentTransition.dismissTapOnTemp = self.dimissTapOnTemp_;
                    self.presentTransition.animationStyle = self.animationStyle_;
                    float delay = 0;
                    if (x.presentedViewController) {
                        delay = kPresentDelay;
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        alert.transitioningDelegate = self.presentTransition;
                        [[self getp_vcFrom:x] presentViewController:alert animated:YES completion:nil];
                    });
                } else if ([self.customAlert isKindOfClass:[UIView class]]) {
                    if ([self.customAlert respondsToSelector:@selector(initWithTitle:message:actions:)]) {
                        self.customAlert = [self.customAlert initWithTitle:self.title_ message:self.message_ actions:self.actions.copy];
                    }
                    UIView *onView = x ? x.view : v;
                    self.viewTransition = [[PopoAlertViewTransition alloc] initWithCustomAlertView:(UIView *)self.customAlert onView:onView];
                    self.viewTransition.dismissTapOnTemp = self.dimissTapOnTemp_;
                    self.viewTransition.animationStyle = self.animationStyle_;
                    [self.viewTransition show];
                }
            }
        });
    };
    return maker;
}

- (UIViewController *)getp_vcFrom:(UIViewController *)x {
    UIViewController *p = x;
    while (p) {
        UIViewController *x_p = p.presentedViewController;
        if (!x_p) {
            break;
        }
        p = x_p;
    }
    return p;
}

@end


@implementation PopoAlertMaker (PopoAlertCustom)

+ (PopoAlertCustom)custom {
    return ^PopoAlertMaker *(id<PopoAlertContentProtocol> x) {
        PopoAlertMaker *maker = [[PopoAlertMaker alloc] initWithAlertStyle:PopoAlertControllerStyleCustom custom:x];
        return maker;
    };
}

/// 默认是点击空白处不会消失的
- (PopoAlertMaker * (^)(BOOL))dimissTapOnTemp {
    PopoAlertMaker *(^maker)(BOOL) = ^PopoAlertMaker *(BOOL x) {
        self.dimissTapOnTemp_ = x;
        return self;
    };
    return maker;
}

- (PopoAlertMaker * (^)(PopoAlertAnimation))animationStyle {
    PopoAlertMaker *(^maker)(PopoAlertAnimation) = ^PopoAlertMaker *(PopoAlertAnimation x) {
        self.animationStyle_ = x;
        return self;
    };
    return maker;
}

@end

#pragma mark - Controller Present caegory

@implementation UIViewController (PopoAlertPresent)

- (PopoAlertMaker *)popo_alertMaker {
    PopoAlertMaker *maker = [[PopoAlertMaker alloc] initWithAlertStyle:PopoAlertControllerStyleCustom custom:(id<PopoAlertContentProtocol>)self];
    return maker;
}

- (PopoAlertMaker *)popo_presentFrom:(UIViewController *)from {
    PopoAlertMaker *maker = self.popo_alertMaker;
    maker.presentFrom(from);
    return maker;
}

- (void)popo_dismissToPresent:(void (^)(UIViewController * _Nonnull))present {
    __weak typeof(self.presentingViewController) w_p = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        __strong typeof(w_p) s_p = w_p;
        if (!s_p) return;
        if (present) {
            present(s_p);
        }
    }];
}

- (void)popo_setNeedsUpdateFrameOfContentViewWithAnimate:(BOOL)animate {
    if ([self respondsToSelector:@selector(frameForViewContent)]) {
        objc_setAssociatedObject(self, kSetNeedsUpdateFrameKey, @(animate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        // 强制触发‘containerViewDidLayoutSubviews’，直接调用‘setNeedsLayout’无效果
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width + 1, self.view.frame.size.height);
    }
}

@end


@implementation UIView (PopoAlertPresent)

- (void)popo_dismissAlertView {
    PopoAlertViewTransition *t = objc_getAssociatedObject(self, kCustomAlertBindViewTransitionKey);
    if (t) {
        [t dismiss];
    }
}

- (void)popo_setAlertViewHidden:(BOOL)hidden {
    PopoAlertViewTransition *t = objc_getAssociatedObject(self, kCustomAlertBindViewTransitionKey);
    if (t) {
        [t setHidden:hidden];
    }
}

- (void)popo_setNeedsUpdateFrameOfContentViewWithAnimate:(BOOL)animate {
    PopoAlertViewTransition *t = objc_getAssociatedObject(self, kCustomAlertBindViewTransitionKey);
    if (t) {
        [t setNeedsUpdateFrameWithAnimate:animate];
    }
}

@end

@implementation PopoAlertMaker (PopoCustomImpl)

@end


