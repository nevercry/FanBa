//
//  UsersWithStatusCountCDTVC.h
//  FanBa
//
//  Created by nevercry on 13-5-31.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "RSFanFouEngine.h"

@interface UsersWithStatusCountCDTVC : CoreDataTableViewController<RSFanFouEngineDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) UIButton *accountButton;

- (IBAction)done:(UIStoryboardSegue *)segue;
- (IBAction)cancel:(UIStoryboardSegue *)segue;

@end
