//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"

#define REFRESH_HEADER_HEIGHT 30.0f

@interface PullRefreshTableViewController ()

@property (nonatomic,assign) NSInteger lastContentOffset;
@property (nonatomic,assign) BOOL isUpScroll;
 
@end

@implementation PullRefreshTableViewController


- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  //[self addPullToRefreshHeader];
  [self addPullToRefreshFooter];
}

- (void)setupStrings{
    self.hasMore = YES;
}

-(void)addPullToRefreshFooter{
    self.refreshFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.tableView.frame.size.width, REFRESH_HEADER_HEIGHT)];
    self.refreshFooterView.backgroundColor = [UIColor clearColor];

    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(floorf(floorf(self.tableView.frame.size.width / 2)), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;

    [self.refreshFooterView addSubview:self.refreshSpinner];
    self.tableView.tableFooterView = self.refreshFooterView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
    
    self.lastContentOffset = scrollView.contentOffset.y;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.isUpScroll = NO;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.isUpScroll = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isLoading || !self.hasMore) return;
    isDragging = NO;
    
//    CGPoint offset = scrollView.contentOffset;
//    CGRect bounds = scrollView.bounds;
//    CGSize size = scrollView.contentSize;
//    UIEdgeInsets inset = scrollView.contentInset;
//    CGFloat currentOffset = offset.y + bounds.size.height - inset.bottom;
//    
//    CGFloat maximumOffset = size.height;
//    
//    (maximumOffset - currentOffset) <= -REFRESH_HEADER_HEIGHT)
        
    //上拉刷新
    

//    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= 0 && self.isUpScroll ){
//        
//        NSLog(@"contetsize.heigth is %f, scrollBuounds.hei is %f scrll.contInset.buttom is %f",scrollView.contentSize.height,scrollView.bounds.size.height,scrollView.contentInset.bottom);
//        [self startLoading];
//    }
//    
//    NSLog(@"scrollView.off.y is %f",scrollView.contentOffset.y);

    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= 0 && self.isUpScroll ){
        
        NSLog(@"contetsize.heigth is %f, scrollBuounds.hei is %f scrll.contInset.buttom is %f",scrollView.contentSize.height,scrollView.bounds.size.height,scrollView.contentInset.bottom);
        [self startLoading];
    }
    
    NSLog(@"scrollView.off.y is %f",scrollView.contentOffset.y);
    
}

- (void)startLoading {
    isLoading = YES;

    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.refreshSpinner startAnimating];
    [UIView commitAnimations];

    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;

    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    tableContentInset.top = 0.0;
    self.tableView.contentInset = tableContentInset;
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    NSLog(@"%f",self.tableView.contentSize.height);
    
    
    [self.refreshSpinner stopAnimating];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
    
}



@end
