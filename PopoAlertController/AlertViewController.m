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
    [self popo_dismissToPresent:^(UIViewController * _Nonnull p) {
        PopoAlertMaker.sheet.message(@"二次弹框").
        presentFrom(p);
    }];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<PopoAlertAction *> *)actions {
    self = [super init];
    if (self) {
        for (PopoAlertAction *action in actions) {
            NSLog(@"title:%@|userInfo:%@",action.title,action.userInfo);
        }
    }
    return self;
}

- (CGRect)initialFrameForViewContent {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return CGRectMake((size.width - 200 * 1.3) / 2, (size.height - 200 * 1.3) / 2, 200 * 1.3, 120 * 1.3);
}

- (CGRect)frameForViewContent {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return CGRectMake((size.width - 200) / 2, (size.height - 200) / 2, 200, 120);
}


@end
