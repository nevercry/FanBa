//
//  UserListViewController.m
//  FanBa
//
//  Created by nevercry on 13-7-25.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UserListViewController.h"
#import "FBCoreData.h"
#import "UserListTVCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+NetworkActivity.h"
#import "SVProgressHUD.h"

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine

@interface UserListViewController ()

@property (nonatomic,strong) NSMutableArray *users;
@property (nonatomic,strong) NSMutableDictionary *userThumbnail;

@end

@implementation UserListViewController


- (void)setUserName:(NSString *)userName
{
    _userName = userName;
    self.title = @"关注者";
}

- (NSMutableDictionary *)userThumbnail
{
    if (!_userThumbnail) {
        _userThumbnail = [NSMutableDictionary dictionary];
    }
    
    return _userThumbnail;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SHARED_FANFOU_ENGINE.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.users) {
        [SHARED_FANFOU_ENGINE showFollowers:self.userName withCompletionBlock:^(NSError *error, MKNetworkOperation *response){
            if (error) {
                NSLog(@"public show error %@",error);
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"账号已设置隐私保护"
                                                                    message:@"你还没有通过这个用户的验证"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确认"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                
            } else {
                self.users = [NSMutableArray arrayWithArray:response.responseJSON];
                [self.tableView reloadData];
            }
        }];
    }
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserListTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListTVCell" forIndexPath:indexPath];
    
    NSDictionary *user = [self.users objectAtIndex:indexPath.row];
    
    cell.user = user;
    
    // Configure the cell...
    
    
    
    
    
    if (!self.userThumbnail[user[FANFOU_USER_ID]]) {
        NSString *imageURLStr = user[FANFOU_USER_PROFILE_IMAGE_URL];
        NSURL *imageURL = [NSURL URLWithString:imageURLStr];
        dispatch_queue_t imageFethQ = dispatch_queue_create("imageFetchQ", NULL);
        dispatch_async(imageFethQ, ^{
            [UIApplication toggleNetworkActivityIndicatorVisible:YES];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            [UIApplication toggleNetworkActivityIndicatorVisible:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageData) {
                    self.userThumbnail[user[FANFOU_USER_ID]] = [UIImage imageWithData:imageData];
                    cell.thumbnailImage = self.userThumbnail[user[FANFOU_USER_ID]];
                }
            });
        });
    } else {
        cell.thumbnailImage = self.userThumbnail[user[FANFOU_USER_ID]];
    }

    
    
    return cell;
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


#pragma mark - RSFanFouEngine Delegate Methods
- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url
{
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
}

#pragma mark - AlertView Delagate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES)];
}


@end
