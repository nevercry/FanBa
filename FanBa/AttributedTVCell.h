//
//  AttributedTVCell.h
//  FanBa
//
//  Created by nevercry on 13-6-28.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class Status;

@interface AttributedTVCell : UITableViewCell<TTTAttributedLabelDelegate>

@property (nonatomic, strong) Status *status;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSTimer *timer;





@end
