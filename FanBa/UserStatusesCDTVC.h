//
//  UserStatusesCDTVC.h
//  FanBa
//
//  Created by nevercry on 13-6-4.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "User.h"
#import "TTTAttributedLabel.h"

@interface UserStatusesCDTVC : CoreDataTableViewController<TTTAttributedLabelDelegate>

@property  (nonatomic,strong) User *user;


@end
