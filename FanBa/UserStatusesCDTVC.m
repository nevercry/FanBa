//
//  UserStatusesCDTVC.m
//  FanBa
//
//  Created by nevercry on 13-6-4.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UserStatusesCDTVC.h"
#import "AttributedTVCell.h"
#import "Status.h"
#import <QuartzCore/QuartzCore.h>
#import "SVWebViewController.h"

@interface UserStatusesCDTVC ()

@end

@implementation UserStatusesCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - Properties

- (void)setUser:(User *)user
{
    _user = user;
    self.title = user.name;
    [self setupFetchedResultsControllerWithPredicate:nil];
}

- (void)setupFetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    if (self.user.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rawid" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"whoSent = %@",self.user];
        if (predicate) {
            request.predicate = predicate;
        }
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.user.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttributedTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttributedCell"];
    Status *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.status = status;

    
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




@end
