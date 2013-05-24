//
//  WebViewController.m
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController


- (void)setCurrentURL:(NSURL *)currentURL
{
    _currentURL = currentURL;
}

#pragma mark - View Lifecycle

- (void)viewDidLayoutSubviews
{
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.currentURL]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - UIWebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"rsfanfouengine"]) {
        self.currentURL = request.URL;
        [self performSelector:@selector(backToHomeLine:) withObject:self.currentURL afterDelay:1];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    if ([self.currentURL.scheme isEqualToString:@"rsfanfouengine"]) {
        [self performSegueWithIdentifier:@"doneAuthorize" sender:webView];
    }
   
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (![self.currentURL.scheme isEqualToString:@"rsfanfouengine"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)backToHomeLine:(id)sender
{
    [self performSegueWithIdentifier:@"doneAuthorize" sender:sender];
}








@end
