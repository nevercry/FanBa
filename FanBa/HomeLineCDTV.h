//
//  HomeLineCDTV.h
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "RSFanFouEngine.h"
#import "TTTAttributedLabel.h"

@interface HomeLineCDTV : CoreDataTableViewController<RSFanFouEngineDelegate,TTTAttributedLabelDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
