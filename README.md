# AlertMaker

使用方式
##### Alert
```
PopoAlertMaker.alert.title(@"弹框Alert").message(@"描述").addDestructiveAction(@"毁灭性的", ^{
        PopoAlertMaker.alert.message(@"弹框Alert").addDestructiveAction(@"操作000", ^{
            NSLog(@"000");
        }).addDefaultAction(@"操作111", ^{
            NSLog(@"111");
        }).presentFrom(self);
    }).addDefaultAction(@"操作111", ^{
        NSLog(@"111");
    }).addDefaultAction(@"操作222", ^{
        NSLog(@"222");
    }).addForbidAction(@"禁止操作333", ^{
        NSLog(@"333");
    }).presentFrom(self);
```

#### Sheet
```
PopoAlertMaker.sheet.title(@"弹框Sheet").message(@"描述").addDestructiveAction(@"毁灭性的", ^{
        NSLog(@"000");
    }).addDefaultAction(@"present跳转控制器", ^{
        AlertViewController *vc = [[AlertViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }).addDefaultAction(@"push控制器", ^{
        AlertViewController *vc = [[AlertViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }).addForbidAction(@"继续推出Sheet", ^{
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
```

--------
### 自定义弹框
```
PopoAlertMaker.custom([AlertViewController new]).dimissTapOnTemp(YES).presentFrom(self);
```
