//
//  WebViewController.h
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,retain) NSURL *currentURL;
@property (weak, nonatomic) IBOutlet UIWebView *webView;



@end
