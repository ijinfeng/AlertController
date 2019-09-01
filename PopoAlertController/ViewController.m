//
//  ViewController.m
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "ViewController.h"
#import "AlertViewController.h"
#import "PopoAlertMaker.h"
#import "PullDownViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)actionForAlert:(id)sender {
    PopoAlertMaker.alert.title(@"弹框Alert").message(@"描述").addDestructiveAction(@"二级Alert", ^{
        PopoAlertMaker.alert.message(@"弹框Alert").
        addDestructiveAction(@"操作000", ^{
            NSLog(@"000");
        }).addDefaultAction(@"操作111", ^{
            NSLog(@"111");
        }).presentFrom(self);
    }).addDefaultAction(@"操作111", ^{
        NSLog(@"111");
    }).addDefaultAction(@"Pull down", ^{
        PullDownViewController *pulldown = [[PullDownViewController alloc] init];
        pulldown.popo_alertMaker.title(@"我是tip标题")
        .dimissTapOnTemp(YES)
        .presentFrom(self);
    }).addForbidAction(@"禁止操作333", ^{
        NSLog(@"333");
    }).presentFrom(self);
}

- (IBAction)actionForSheet:(id)sender {
    PopoAlertMaker.sheet.title(@"弹框Sheet").message(@"描述").addDestructiveAction(@"毁灭性的", ^{
        AlertViewController *vc = [[AlertViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }).addDefaultAction(@"present跳转控制器", ^{
        AlertViewController *vc = [[AlertViewController alloc] init];
        vc.popo_alertMaker.dimissTapOnTemp(YES).addCustomAction(@"按钮1", @"对象是字符串", ^{
            NSLog(@"");
        }).title(@"我是标题");
        [vc popo_presentFrom:self];
    }).addDefaultAction(@"push控制器", ^{
        AlertViewController *vc = [[AlertViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }).addForbidAction(@"禁止", ^{
        PopoAlertMaker.sheet.message(@"测试二级联动").addDestructiveAction(@"Alert", ^{
            PopoAlertMaker.alert.message(@"sheet2").addDestructiveAction(@"毁灭性的", ^{
                NSLog(@"000");
            }).addDefaultAction(@"sheet", ^{
                NSLog(@"111");
            }).presentFrom(self);
        }).addDefaultAction(@"sheet", ^{
            PopoAlertMaker.sheet.message(@"sheet2").addDestructiveAction(@"毁灭性的", ^{
                NSLog(@"000");
            }).addDefaultAction(@"sheet", ^{
                NSLog(@"111");
            }).presentFrom(self);
            
        }).presentFrom(self);
    }).presentFrom(self);
}

- (IBAction)actionForCustom:(id)sender {
    
    PopoAlertMaker.custom([AlertViewController new]).
    addCustomAction(@"自定义参数", @{@"cmd":@"111"}, ^{
        NSLog(@"点击自定义参数");
    }).
    addDefaultAction(@"点我", ^{
        NSLog(@"点我，e呵呵哒");
    }).dimissTapOnTemp(YES).presentFrom(self);
    
//    AlertViewController *alert = [AlertViewController new];
//    [alert popo_presentFrom:self].dimissTapOnTemp(YES);
}


@end
