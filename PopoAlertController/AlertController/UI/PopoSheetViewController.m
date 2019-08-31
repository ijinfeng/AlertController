//
//  PopoSheetViewController.m
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "PopoSheetViewController.h"
#import "PopoSheetDefaultCell.h"
#import "PopoSheetHeaderView.h"
#import "PopoAlertMaker.h"

static int kSheetDefaultRowHeight = 54;

static inline BOOL isIphonex_s() {
    CGSize size = [UIScreen mainScreen].bounds.size;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    return ((isLandscape ? size.width :size.height) == 812
            || (isLandscape ? size.width :size.height) == 896);
}

@interface PopoSheetViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString *title_;
@property (nonatomic, copy) NSString *message_;
@property (nonatomic, strong) NSArray *actions_;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation PopoSheetViewController

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray<PopoAlertAction *> *)actions {
    self = [super init];
    if (self) {
        _title_ = title;
        _message_ = message;
        _actions_ = actions;
        [self calContentHeight];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PopoSheetDefaultCell" bundle:nil] forCellReuseIdentifier:@"default"];
    [self.tableView registerClass:[PopoSheetHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];
}

- (CGRect)frameForViewContent {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat width = MIN(size.width, size.height);
    return CGRectMake((size.width - width) / 2, size.height - _contentHeight, width, _contentHeight);
}

- (PopoAlertAnimation)alertAnimation {
    return PopoAlertAnimationSheet;
}

- (void)viewDidLayoutSubviews {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:path.CGPath];
    self.view.layer.mask = shape;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.actions_.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopoSheetDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        PopoAlertAction *action = self.actions_[indexPath.row];
        cell.titleLabel.text = action.title;
        cell.titleLabel.textColor = [action renderColor];
        if (self.message_.length == 0
            && indexPath.row == 0) {
            cell.showTopLine = NO;
        } else {
            cell.showTopLine = YES;
        }
    } else {
        cell.showTopLine = NO;
        cell.titleLabel.text = @"取消";
        cell.titleLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        PopoAlertAction *action = self.actions_[indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            action.action();
        });
    } else {
        // cancel
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSheetDefaultRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self calHeadHeight];
    } else {
        return 10;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        PopoSheetHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
        if (!header) {
            header = [[PopoSheetHeaderView alloc] initWithReuseIdentifier:@"header"];
        }
        header.message = self.message_;
        return header;
    } else {
        return [UITableViewHeaderFooterView new];
    }
}

#pragma mark - Calculate

- (CGFloat)calHeadHeight {
    return [PopoSheetHeaderView heightForMessage:self.message_];
}

- (void)calContentHeight {
    _contentHeight = self.actions_.count * kSheetDefaultRowHeight + (isIphonex_s() ? 88 : kSheetDefaultRowHeight) + [self calHeadHeight] + 10;
}

@end
