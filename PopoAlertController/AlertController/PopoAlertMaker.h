//
//  PopoAlertMaker.h
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopoAlertContentProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class PopoAlertMaker, UIViewController, PopoAlertAction;
typedef PopoAlertMaker * _Nonnull(^PopoActionBlock)(NSString *, void(^ _Nullable )(void));
typedef PopoAlertMaker * _Nonnull(^PopoCustomActionBlock)(NSString *, id _Nullable object, void(^ _Nullable )(void));
typedef PopoAlertMaker * _Nonnull(^PopoAlertTitle)(NSString *);
@interface PopoAlertMaker : NSObject

/// 系统alert
+ (PopoAlertMaker *)alert;
/// 系统sheet
+ (PopoAlertMaker *)sheet;

/// 标题设置对sheet无效
@property (nonatomic, copy, readonly) PopoAlertTitle title;
@property (nonatomic, copy, readonly) PopoAlertTitle message;
/// 警告按钮
@property (nonatomic, copy, readonly) PopoActionBlock addDestructiveAction;
/// 默认按钮
@property (nonatomic, copy, readonly) PopoActionBlock addDefaultAction;
/// 禁止按钮
@property (nonatomic, copy, readonly) PopoActionBlock addForbidAction;
@property (nonatomic, copy, readonly) PopoActionBlock addCancelAction;
/// 添加自动义操作，可以传递自定义的参数进去，实现复杂的弹框
@property (nonatomic, copy, readonly) PopoCustomActionBlock addCustomAction;

@property (nonatomic, copy, readonly) void (^presentFrom)(id viewOrViewController);

@end


typedef PopoAlertMaker * _Nonnull(^PopoAlertCustom)(id<PopoAlertContentProtocol>);
/// Alert Custom
@interface PopoAlertMaker (PopoAlertCustom)
/// 传入遵守Protocol<PopoAlertContentProtocol>的UIViewController实例
@property (nonatomic, copy, readonly, class) PopoAlertCustom custom;
/// 点击空白处是否dismissm，注意只有设置为custom的弹框才有效
@property (nonatomic, copy, readonly) PopoAlertMaker * _Nonnull(^dimissTapOnTemp)(BOOL);
/// 弹框展示的动画类型，默认是‘PopoAlertAnimationStyleAlert’类型
@property (nonatomic, copy, readonly) PopoAlertMaker * _Nonnull(^animationStyle)(PopoAlertAnimation);
@end


#pragma mark - Alert Action

typedef NS_ENUM(NSInteger, PopoAlertActionStyle) {
    PopoAlertActionStyleDefault,
    PopoAlertActionStyleDestructive,
    PopoAlertActionStyleForbid,
    PopoAlertActionStyleCancel,
    PopoAlertActionStyleCustom,
};

@interface PopoAlertAction : NSObject

@property (nonatomic, copy) void(^action)(void);

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong, nullable) id object;

@property (nonatomic) PopoAlertActionStyle actionStyle;

@end



@interface UIViewController (PopoAlertPresent)

@property (nonatomic, strong, readonly) PopoAlertMaker *popo_alertMaker;

- (PopoAlertMaker *)popo_presentFrom:(UIViewController *)from;
/// 先dismiss再present
- (void)popo_dismissToPresent:(void(^)(UIViewController *p))present;
/// 当present的自定义的弹窗需要更新其视图frame的时候调用这个方法，会重新调用`- (CGRect)frameForViewContent`
- (void)popo_setNeedsUpdateFrameOfContentViewWithAnimate:(BOOL)animate;

@end

@interface UIView (PopoAlertPresent)

- (void)popo_dismissAlertView;

- (void)popo_setAlertViewHidden:(BOOL)hidden;

- (void)popo_setNeedsUpdateFrameOfContentViewWithAnimate:(BOOL)animate;

@end

#pragma mark - Custom IMP

@interface PopoAlertMaker (PopoCustomImpl)

@end


NS_ASSUME_NONNULL_END
