//
//  PublicTimeLineViewController.m
//  FanBa
//
//  Created by nevercry on 13-6-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "PublicTimeLineViewController.h"
#import "FBCoreData.h"
#import "StatusTVCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SVWebViewController.h"
#import "UserProfileViewController.h"
#import "TTTAttributedLabel.h"

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine

@interface PublicTimeLineViewController ()

@property (nonatomic,strong) NSMutableArray *statuses;
@property (nonatomic,strong) NSMutableDictionary *userThumbnail;
@end

@implementation PublicTimeLineViewController


#pragma mark - Property

- (void)setStatuses:(NSMutableArray *)statuses
{
    _statuses = statuses;
}

- (NSMutableDictionary *)userThumbnail
{
    if (!_userThumbnail) {
        _userThumbnail = [NSMutableDictionary dictionary];
    }
    
    return _userThumbnail;
}




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SHARED_FANFOU_ENGINE.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.statuses) {
        [SHARED_FANFOU_ENGINE showPublicTimeLineWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
            if (error) {
                NSLog(@"public show error %@",error);
            } else {
                self.statuses = [NSMutableArray arrayWithArray:response.responseJSON];
                [self.tableView reloadData];
                
                
            }
        }];
    }
}

- (void)refresh
{
    [self.refreshControl beginRefreshing];
    [SHARED_FANFOU_ENGINE showPublicTimeLineWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
        if (error) {
            NSLog(@"refresh public error %@",error);
        } else {
            if (self.statuses) {
                NSMutableArray *newStatuses = [NSMutableArray array];
                for (NSDictionary *statusInfo in (NSArray *)response.responseJSON) {
                    if (![self.statuses containsObject:statusInfo]) [newStatuses addObject:statusInfo];
                }
                
                NSRange range;
                range.location = 0;
                range.length = [newStatuses count];
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                
                [self.statuses insertObjects:newStatuses atIndexes:indexSet];;
                [self.tableView reloadData];
               
            }
        }
    }];
    
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RSFanFouEngine Delegate Methods
- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url
{
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatusTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell"];
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    NSDictionary *user = status[FANFOU_STATUS_USER];
    NSURL *url = [NSURL URLWithString:user[FANFOU_USER_PROFILE_IMAGE_URL]];
    NSString *userName = user[FANFOU_USER_NAME];
    
    
    
    
    cell.user = user;
    cell.status = status;

    
    if (!self.userThumbnail[userName]) {
        dispatch_queue_t imageQueue = dispatch_queue_create("image fetch", NULL);
        dispatch_async(imageQueue, ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            [self.userThumbnail setObject:imageData forKey:userName];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageData) {
                    cell.thumbnailImage = [UIImage imageWithData:imageData];
                }
            });
        });
    } else {
        UIImage *image = [UIImage imageWithData:self.userThumbnail[userName]];
        cell.thumbnailImage = image;
    }
    
        
    
    
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake((tableView.frame.size.width - 70.0f), 20000.0f);
    
    NSString *statusText = status[FANFOU_STATUS_TEXT];
    
    //-----------custom handle the text height---------
    // Regex to find the <a href=/** and replace them
    NSString *htmlPattern = @"<a href=\"([^\"]+)\"[^>]*>([^<]+)</a>";
    
    NSRegularExpression *htmlRex = [NSRegularExpression regularExpressionWithPattern:htmlPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSString *replacedString = [htmlRex stringByReplacingMatchesInString:statusText options:NSMatchingReportCompletion range:NSMakeRange(0, statusText.length) withTemplate:@"$2"];
    
    //-------------------------------------------------
    
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    
    CGRect rect = [replacedString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic context:context];
    
    CGFloat height = ceil(rect.size.height);

    
     height = MAX(height,20.0f);
    
    return height + 40.0f;
    
    
    
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



#pragma mark - custom method


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
