//
//  HomeLineTVCell.h
//  FanBa
//
//  Created by nevercry on 13-8-1.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTTAttributedLabel.h"
@class Status;
@class User;

@interface HomeLineTVCell : UITableViewCell<TTTAttributedLabelDelegate>

@property (nonatomic, strong) Status *status;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSTimer *timer;


@end
