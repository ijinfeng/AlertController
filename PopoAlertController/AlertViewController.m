//
//  AlertViewController.m
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "AlertViewController.h"
#import "PopoAlertMaker.h"

@interface AlertViewController ()
<<<<<<< HEAD
@property (nonatomic, assign) BOOL change;
=======

>>>>>>> 01fbdfe5a175c31f56212f0947386a4913a0fcf7
@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    __weak typeof(self.presentingViewController) w_p = self.presentingViewController;
//    [self dismissViewControllerAnimated:YES completion:^{
//        __strong typeof(w_p) s_p = w_p;
//        PopoAlertMaker.sheet.message(@"二次弹框").
//        presentFrom(s_p);
//    }];
<<<<<<< HEAD
//    [self popo_dismissToPresent:^(UIViewController * _Nonnull p) {
//        PopoAlertMaker.sheet.message(@"二次弹框").
//        presentFrom(p);
//    }];
    self.change = !self.change;
    [self popo_setNeedsUpdateFrameOfContentViewWithAnimate:YES];
=======
    [self popo_dismissToPresent:^(UIViewController * _Nonnull p) {
        PopoAlertMaker.sheet.message(@"二次弹框").
        presentFrom(p);
    }];
>>>>>>> 01fbdfe5a175c31f56212f0947386a4913a0fcf7
}

- (CGRect)frameForViewContent {
    CGSize size = [UIScreen mainScreen].bounds.size;
<<<<<<< HEAD
    CGFloat height = self.change ? 200 : 120;
    return CGRectMake((size.width - 200) / 2, (size.height - height) / 2, 200, height);
=======
    return CGRectMake((size.width - 200) / 2, (size.height - 200) / 2, 200, 120);
>>>>>>> 01fbdfe5a175c31f56212f0947386a4913a0fcf7
}

- (UIColor *)animationTransitionColor {
    return [[UIColor redColor] colorWithAlphaComponent:0.5];
}

@end
