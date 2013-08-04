//
//  StatusTVCell.h
//  FanBa
//
//  Created by nevercry on 13-6-4.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface StatusTVCell : UITableViewCell<TTTAttributedLabelDelegate>

@property (nonatomic,strong) NSDictionary *status;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) UIImage* thumbnailImage;

@end
