//
//  PullDownViewController.m
//  PopoAlertController
//
//  Created by JinFeng on 2019/9/1.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "PullDownViewController.h"

@interface PullDownViewController ()
@property (nonatomic, strong) NSString *m_title;
@end

@implementation PullDownViewController

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<PopoAlertAction *> *)actions {
    self = [super init];
    if (self) {
        _m_title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = _m_title ? _m_title : @"我是TIP";
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
    [self.view addSubview:label];
}

- (CGRect)frameForViewContent {
    return CGRectMake(0,0,self.view.bounds.size.width, 120);
}

- (PopoAlertAnimation)alertAnimation {
    return PopoAlertAnimationPullDown;
}

- (UIColor *)animationTransitionColor {
    return [UIColor redColor];
}

@end
