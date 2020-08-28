//
//  PopoSheetDefaultCell.h
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopoSheetDefaultCell : UITableViewCell

@property (weak, nonatomic, readonly) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) BOOL showTopLine;

@end

NS_ASSUME_NONNULL_END
