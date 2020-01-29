//
//  PopoSheetHeaderView.h
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopoSheetHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy, nullable) NSString *message;

+ (CGFloat)heightForMessage:(NSString *)message;


@end

NS_ASSUME_NONNULL_END
