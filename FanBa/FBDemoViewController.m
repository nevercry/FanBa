//
//  FBDemoViewController.m
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "FBDemoViewController.h"
#import "WebViewController.h"

@interface FBDemoViewController ()

@end

@implementation FBDemoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fanfouEngine = [[RSFanFouEngine alloc] initWithDelegate:self];
    
    // A right swipe on the status label will clear the stored token
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.numberOfTouchesRequired = 1;
    [self.statusLabel.superview addGestureRecognizer:swipeRight];
    
    // check if the user is already authenticated
    if (self.fanfouEngine.isAuthenticated) {
        self.statusLabel.text = [NSString stringWithFormat:@"Signed in as @%@.",self.fanfouEngine.screenName];
    } else {
        self.statusLabel.text = @"Not signed in.";
    }
    
    [self.textView becomeFirstResponder];
}


#pragma mark - RSFanFouEngine Delegate Methods

- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url
{
    [self performSegueWithIdentifier:@"setCurrentURL:" sender:url];
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
    self.statusLabel.text = message;
}




#pragma mark - Custom Method

- (void)swipeRight:(UIGestureRecognizer *)recognizer
{
    if (self.fanfouEngine) [self.fanfouEngine forgetStoredToken];
    self.statusLabel.text = @"Not signed in.";
}

- (IBAction)sendTweet:(UIBarButtonItem *)sender
{
    if (self.fanfouEngine) {
        self.sendButton.enabled = NO;
        
        [self.fanfouEngine sentTweet:self.textView.text withCompletionBlock:^(NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送消息"
                                                                message:@"消息发送成功!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:nil];
                [alert show];
                
                self.textView.text =@"";
            }
            
            self.sendButton.enabled = YES;
            
            if (self.fanfouEngine.isAuthenticated) {
                self.statusLabel.text = [NSString stringWithFormat:@"Signed in as @%@",self.fanfouEngine.screenName];
            } else {
                self.statusLabel.text = @"Not signed in.";
            }
        }];
    }
}

#pragma mark - Segue

- (IBAction)done:(UIStoryboardSegue *)segue
{
    WebViewController *vc = (WebViewController *)segue.sourceViewController;
    if ([vc.currentURL.query hasPrefix:@"denied"]) {
        if (self.fanfouEngine) [self.fanfouEngine cancelAuthentication];
    } else {
        if (self.fanfouEngine) [self.fanfouEngine resumeAuthenticationFlowWithURL:vc.currentURL];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setCurrentURL:"]) {
        WebViewController *vc = (WebViewController *)segue.destinationViewController;
        if ([vc respondsToSelector:@selector(setCurrentURL:)]) {
            [vc performSelector:@selector(setCurrentURL:) withObject:sender];
        }
    }
}

// this happened when user tap cancel button in the webView
- (IBAction)dismissWebView:(UIStoryboardSegue *)segue
{
    if (self.fanfouEngine) [self.fanfouEngine cancelAuthentication];
}




@end
