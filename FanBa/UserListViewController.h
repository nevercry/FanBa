//
//  UserListViewController.h
//  FanBa
//
//  Created by nevercry on 13-7-25.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFanFouEngine.h"
#import "PullRefreshTableViewController.h"

@interface UserListViewController : PullRefreshTableViewController<RSFanFouEngineDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSString *userName;

@end
