//
//  UserProfileViewController.h
//  FanBa
//
//  Created by nevercry on 13-6-30.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFanFouEngine.h"

@class TTTQuadrantControl;

@interface UserProfileViewController : UITableViewController<RSFanFouEngineDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property (weak, nonatomic) IBOutlet TTTQuadrantControl *quadrantControl;
@property (weak, nonatomic) IBOutlet UITableViewCell *userDescriptionCell;

@property (strong,nonatomic) NSDictionary *user;
@property (weak, nonatomic) IBOutlet UIImageView *accountProtectImg;



@end
