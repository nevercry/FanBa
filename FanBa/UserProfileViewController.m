//
//  UserProfileViewController.m
//  FanBa
//
//  Created by nevercry on 13-6-30.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UserProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "FBCoreData.h"
#import "UIApplication+NetworkActivity.h"
#import "TTTQuadrantControl.h"
#import "SVProgressHUD.h"

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine


@interface UserProfileViewController ()

@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *userScreen;
@property (nonatomic,strong) NSString *userDescription;

@end

@implementation UserProfileViewController


- (void)setUser:(NSDictionary *)user
{
    if (user != _user) {
        _user = user;
    }
    
    if ([_user[FANFOU_USER_PROTECTED] isEqual: @(YES)]){
        self.accountProtectImg.hidden = NO;
    }
    
    [self.quadrantControl setNumber:_user[FANFOU_USER_FRIENDS_COUNT]
                            caption:@"正在关注"
                             action:@selector(didSelectFollowingQuadrant)
                        forLocation:TopLeftLocation];
    
    [self.quadrantControl setNumber:_user[FANFOU_USER_STATUSES_COUNT]
                            caption:@"消息"
                             action:@selector(didSelectTweetsQuadrant)
                        forLocation:TopRightLocation];
    
    [self.quadrantControl setNumber:_user[FANFOU_USER_FOLLOWERS_COUNT]
                            caption:@"关注者"
                             action:@selector(didSelectFollowersQuandrant)
                        forLocation:BottomLeftLocation];
    
    [self.quadrantControl setNumber:_user[FANFOU_USER_FAVOURITES_COUNT]
                            caption:@"收藏"
                             action:@selector(didSelectFavoritesQuandrant)
                        forLocation:BottomRightLocation];
    
    [self.quadrantControl.topLeftQuadrantView setNeedsDisplay];
    [self.quadrantControl.topRightQuadrantView setNeedsDisplay];
    [self.quadrantControl.bottomLeftQuadrantView setNeedsDisplay];
    [self.quadrantControl.bottomRightQuadrantView setNeedsDisplay];
    [SVProgressHUD dismiss];
    
}

- (void)setUserName:(NSString *)userName
{
    _userName = userName;
    self.title = userName;
    [SVProgressHUD showWithStatus:@"正在载入" maskType:SVProgressHUDMaskTypeBlack];
}

- (void)setUserScreen:(NSString *)userScreen
{
    _userScreen = userScreen;
    self.userScreenNameLabel.text = userScreen;
}

- (void)setUserDescription:(NSString *)userDescription
{
    _userDescription = userDescription;
    self.userDescriptionCell.textLabel.text = _userDescription;
    [self.tableView reloadData];
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
    
    self.avatarImageView.layer.cornerRadius = 8.0f;
	self.avatarImageView.layer.borderWidth = 1.0f;
	self.avatarImageView.layer.masksToBounds = YES;
	self.avatarImageView.layer.borderColor = [[UIColor clearColor] CGColor];
    
    self.quadrantControl.delegate = self;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"unique_id == %@",self.userName];
    NSError *error;
    NSArray *items = [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"itmes count is %lu",(unsigned long)[items count]);
    
    if ([items count] > 0 && [items count] < 2) {
        User *user = [items lastObject];
        self.userScreen = user.screen_name;
        self.userDescription = user.user_despcription;
        self.userNameLabel.text = self.title;
        self.avatarImageView.image = [UIImage imageWithData:user.thumbnail];
        
        [self.quadrantControl setNumber:user.friends_count
                                caption:@"正在关注"
                                 action:@selector(didSelectFollowingQuadrant)
                            forLocation:TopLeftLocation];
        
        [self.quadrantControl setNumber:user.statuses_count
                                caption:@"消息"
                                 action:@selector(didSelectTweetsQuadrant)
                            forLocation:TopRightLocation];
        
        [self.quadrantControl setNumber:user.followers_count
                                caption:@"关注者"
                                 action:@selector(didSelectFollowersQuandrant)
                            forLocation:BottomLeftLocation];
        
        [self.quadrantControl setNumber:user.favorites_count
                                caption:@"收藏"
                                 action:@selector(didSelectFavoritesQuandrant)
                            forLocation:BottomRightLocation];
        [SVProgressHUD dismiss];
        
    } else if ([items count] > 1){
        NSLog(@"error match greater than 1");
    } else if ([items count] == 0) {
        SHARED_FANFOU_ENGINE.delegate = self;
        [SHARED_FANFOU_ENGINE showUser:self.userName WithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
            if (error) {
                NSLog(@"show user error %@",error);
                [SVProgressHUD dismiss];
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:1];
            } else {
                NSDictionary *userInfo = response.responseJSON;
                self.userScreen = userInfo[FANFOU_USER_SCREEN_NAME];
                self.userDescription = userInfo[FANFOU_USER_DESCRIPTION];
                self.userNameLabel.text = self.title;
                
                
                
                
                NSURL *thumbnailURL =[NSURL URLWithString:userInfo[FANFOU_USER_PROFILE_IMAGE_URL]];
                
                if (thumbnailURL) {
                    dispatch_queue_t imageFetchQ = dispatch_queue_create("image Fetch", NULL);
                    dispatch_async(imageFetchQ, ^{
                        [UIApplication toggleNetworkActivityIndicatorVisible:YES];
                        NSData *thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
                        [UIApplication toggleNetworkActivityIndicatorVisible:NO];
                        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (thumbnailImage) {
                                self.avatarImageView.image = thumbnailImage;
                                self.user = [NSDictionary dictionaryWithDictionary:userInfo];
                                
                            }
                        });
                    });
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CGSize constraint = CGSizeMake((tableView.frame.size.width - 40.0f), 2008.0f);
        CGSize size = [self.userDescription sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = size.height + 10;
        
        return MAX(height, 70)  ;
    } else
        return 51.0;
}

#pragma mark - RSFanFouEngine Delegate Methods
- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url
{
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
}

#pragma mark - Actions

- (void)didSelectFollowingQuadrant {
    
}

- (void)didSelectTweetsQuadrant{
    
}

- (void)didSelectFollowersQuandrant {
    [self performSegueWithIdentifier:@"showFollowers" sender:self.userName];
}

- (void)didSelectFavoritesQuandrant {
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showFollowers"]) {
        [segue.destinationViewController performSelector:@selector(setUserName:) withObject:sender];
    }
}


@end
