//
//  PopoSheetDefaultCell.m
//  PopoAlertController
//
//  Created by JinFeng on 2019/4/23.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "PopoSheetDefaultCell.h"

@interface PopoSheetDefaultCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topLine;

@end

@implementation PopoSheetDefaultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setShowTopLine:(BOOL)showTopLine {
    _showTopLine = showTopLine;
    self.topLine.hidden = !showTopLine;
}

@end
