//
//  FBDemoViewController.h
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFanFouEngine.h"
#import "WebViewController.h"

@interface FBDemoViewController : UIViewController <RSFanFouEngineDelegate>

@property (strong,nonatomic) RSFanFouEngine *fanfouEngine;
@property (strong,nonatomic) WebViewController *webView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)sendTweet:(UIBarButtonItem *)sender;
- (void)swipeRight:(UIGestureRecognizer *)recognizer;
- (IBAction)done:(UIStoryboardSegue *)segue;
- (IBAction)dismissWebView:(UIStoryboardSegue *)segue;


@end
