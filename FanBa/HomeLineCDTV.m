//
//  HomeLineCDTV.m
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "HomeLineCDTV.h"
#import "Status+Create.h"
#import "FBCoreData.h"
#import "HomeLineTVCell.h"
#import "SVWebViewController.h"
#import "TweetComposeViewController.h"
#import "SVProgressHUD.h"
#import <AudioToolbox/AudioToolbox.h>


@interface HomeLineCDTV ()

@end

@implementation HomeLineCDTV

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine


#pragma mark - Properties
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rawid" ascending:NO]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeLineTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeLineTVCell"];
    Status *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.status = status;
    cell.user = status.whoSent;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Status *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGSize constraint = CGSizeMake((tableView.frame.size.width - 82.0f), 1000.0f);
    // when device rotated,the width will be different
    
    
    //-----------custom handle the text height---------
    // Regex to find the <a href=/** and replace them
    NSString *htmlPattern = @"<a href=\"([^\"]+)\"[^>]*>([^<]+)</a>";
    
    NSRegularExpression *htmlRex = [NSRegularExpression regularExpressionWithPattern:htmlPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *replacedString = [htmlRex stringByReplacingMatchesInString:status.text options:NSMatchingReportCompletion range:NSMakeRange(0, status.text.length) withTemplate:@"$2"];
    
    //-------------------------------------------------
    
    NSString *htmlToTextstr = [self htmlToText:replacedString];
    
    
    
    CGSize size = [htmlToTextstr sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = MAX(size.height,35);
    
    
    
    
    
    
    return height + 28 +10;
    
}

- (NSString *)htmlToText:(NSString *)htmlString
{
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@"&"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@""""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&#039;"  withString:@"'"];
    
    // Extras
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<3" withString:@"♥"];
    
    // normalize and separate newline from other words
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" \n "];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@" \n "];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\n" withString:@" \n "];
    
    return htmlString;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self useFanBaDocument];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SHARED_FANFOU_ENGINE.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}



- (void)useFanBaDocument
{
    FBCoreData *fanbaCD = [FBCoreData sharedManagedDocument];
    UIManagedDocument *document = fanbaCD.sharedDocument;
    NSURL *url = document.fileURL;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  NSLog(@"manged objectctx create");
                  
                  
              } else {
                  NSLog(@"manged objectctx created fail");
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext  = document.managedObjectContext;
                NSLog(@"context open");
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
        NSLog(@"context");
        
    }

    
    
}


- (void)refresh
{
    [self.refreshControl beginRefreshing];
    [SHARED_FANFOU_ENGINE showHomeLineWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
        if (error) {
            NSLog(@"home line error %@",error);
        } else {
            if (self.managedObjectContext) {
                for (NSDictionary*statusInfo in (NSArray *)response.responseJSON) {
                    [Status statusWithInfo:statusInfo inManagedObjectContext:self.managedObjectContext];
                }
            }
        }
    }];
    [self.refreshControl endRefreshing];
}

#pragma mark - RSFanFouEngine Delegate Methods
- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url
{
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *urlstr = [url scheme];
    
    if ([urlstr isEqualToString:@"fbaccount"]) {
        [self performSegueWithIdentifier:@"showUserProfile" sender:url];
    } else {
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:url];
        [webViewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    
    
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUserProfile"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setUserName:)]) {
            if ([sender isKindOfClass:[NSURL class]]) {
                NSString *urlstr = [(NSURL *)sender lastPathComponent];
                [segue.destinationViewController performSelector:@selector(setUserName:) withObject:urlstr];
                [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
            }
            
        }
    }
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[TweetComposeViewController class]]) {
        TweetComposeViewController *tcvc = segue.sourceViewController;
        
        [SHARED_FANFOU_ENGINE sentTweet:tcvc.tweetTextView.text withCompletionBlock:^(NSError *error) {
            if (error) {
                NSLog(@"sent error");
                [SVProgressHUD showErrorWithStatus:@"发送失败"];
            } else {
                NSLog(@"done");
                [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                AudioServicesPlaySystemSound(1016);
                [self refresh];
            }
        }];
    }
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    
}




@end
