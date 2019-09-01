//
//  PopoAlertMaker.m
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "PopoAlertMaker.h"
#import "PopoSheetViewController.h"
#import <objc/runtime.h>

static const float kPresentDelay = 0.3;

typedef NS_ENUM(int, PopoAlertControllerStyle) {
    PopoAlertControllerStyleAlert,
    PopoAlertControllerStyleSheet,
    PopoAlertControllerStyleCustom,
};

#pragma mark - PresentTranstion

@interface PopoPresentTransition : UIPresentationController<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL dismissTapOnTemp;

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
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)presentationTransitionWillBegin {
    UIViewController *toVC = self.presentedViewController;
    UIColor *backgroundColor = [UIColor blackColor];
    if ([toVC conformsToProtocol:@protocol(PopoAlertContentProtocol)]
        && [toVC respondsToSelector:@selector(animationTransitionColor)]) {
        backgroundColor = [(id<PopoAlertContentProtocol>)toVC animationTransitionColor];
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
        
    }];
}

- (void)actionForTapOnTemp {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dismissalTransitionWillBegin {
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.backgroundView.alpha = 0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
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
        toVC.view.frame = rect;
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
    PopoAlertAnimation animation = PopoAlertAnimationPopAlert;
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
            CGSize size = [UIScreen mainScreen].bounds.size;
            CGRect rect = finalFrame;
            rect.size = CGSizeMake(rect.size.width * 1.3, rect.size.height * 1.3);
            rect.origin = CGPointMake((size.width - rect.size.width) / 2, (size.height - rect.size.height) / 2);
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

@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong) PopoPresentTransition *presentTransition;

@property (nonatomic, strong) id<PopoAlertContentProtocol> viewController;

@end

@implementation PopoAlertMaker

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

- (instancetype)initWithAlertStyle:(PopoAlertControllerStyle)style custom:(id<PopoAlertContentProtocol>)viewController {
    if (self = [super init]) {
        _alertStyle = style;
        _viewController = viewController;
        _dimissTapOnTemp_ = style == PopoAlertControllerStyleSheet;
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

/// 默认是点击空白处不会消失的
- (PopoAlertMaker * (^)(BOOL))dimissTapOnTemp {
    PopoAlertMaker *(^maker)(BOOL) = ^PopoAlertMaker *(BOOL x) {
        self.dimissTapOnTemp_ = x;
        return self;
    };
    return maker;
}

- (void (^)(UIViewController * _Nonnull))presentFrom {
    void (^maker)(UIViewController *) = ^(UIViewController *x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.alertStyle == PopoAlertControllerStyleSheet) {
                PopoSheetViewController *alert = [[PopoSheetViewController alloc] initWithTitle:self.title_ message:self.message_ actions:self.actions.copy];
                self.presentTransition = [[PopoPresentTransition alloc] initWithPresentedViewController:alert presentingViewController:x style:self.alertStyle];
                self.presentTransition.dismissTapOnTemp = self.alertStyle == PopoAlertControllerStyleSheet;
                float delay = 0;
                if (x.presentedViewController) {
                    delay = kPresentDelay;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    alert.transitioningDelegate = self.presentTransition;
                    [x presentViewController:alert animated:YES completion:nil];
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
                    [x presentViewController:alert animated:YES completion:nil];
                });
            } else {
                // custom alert
                self.viewController = [self.viewController initWithTitle:self.title_ message:self.message_ actions:self.actions.copy];
                if (![self.viewController isKindOfClass:[UIViewController class]]) {
                    return;
                }
                UIViewController *alert = (UIViewController *)self.viewController;
                self.presentTransition = [[PopoPresentTransition alloc] initWithPresentedViewController:alert presentingViewController:x style:self.alertStyle];
                self.presentTransition.dismissTapOnTemp = self.dimissTapOnTemp_;
                float delay = 0;
                if (x.presentedViewController) {
                    delay = kPresentDelay;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    alert.transitioningDelegate = self.presentTransition;
                    [x presentViewController:alert animated:YES completion:nil];
                });
            }
        });
    };
    return maker;
}

@end

#pragma mark - Custom

@implementation PopoAlertMaker (PopoAlertCustom)

+ (PopoAlertCustom)custom {
    return ^PopoAlertMaker *(id<PopoAlertContentProtocol> x) {
        PopoAlertMaker *maker = [[PopoAlertMaker alloc] initWithAlertStyle:PopoAlertControllerStyleCustom custom:x];
        return maker;
    };
}

@end

#pragma mark - Controller Present caegory

@implementation UIViewController (PopoAlertPresent)

- (PopoAlertMaker *)popo_alertMaker {
    PopoAlertMaker *maker = objc_getAssociatedObject(self, _cmd);
    if (!maker) {
        maker = [[PopoAlertMaker alloc] initWithAlertStyle:PopoAlertControllerStyleCustom custom:(id<PopoAlertContentProtocol>)self];
        objc_setAssociatedObject(self, _cmd, maker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
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

@end
