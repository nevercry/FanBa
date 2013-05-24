//
//  DemoViewCDTVC.h
//  FanBa
//
//  Created by nevercry on 13-5-24.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "HomeLineCDTV.h"
#import "RSFanFouEngine.h"

@interface DemoViewCDTVC : HomeLineCDTV<RSFanFouEngineDelegate>

@property (strong,nonatomic) RSFanFouEngine *fanfouEngine;

- (IBAction)done:(UIStoryboardSegue *)segue;
- (IBAction)dismissWebView:(UIStoryboardSegue *)segue;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *autherSwitchButton;
@end
