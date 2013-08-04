//
//  UsersWithStatusCountCDTVC.m
//  FanBa
//
//  Created by nevercry on 13-5-31.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UsersWithStatusCountCDTVC.h"
#import "User+Created.h"
#import "Status+Create.h"
#import "UserWithStatusCountTVCell.h"
#import "FBCoreData.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "UIApplication+NetworkActivity.h"
#import "TweetComposeViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine

@interface UsersWithStatusCountCDTVC ()

@property (nonatomic,strong) User *account;

@end

@implementation UsersWithStatusCountCDTVC

#pragma mark - Properties
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    
    if (managedObjectContext != _managedObjectContext) {
        _managedObjectContext = managedObjectContext;
    }
    
    [self setupFetchController];
    [self setupAccount];
}

- (void)setAccountButton:(UIButton *)accountButton
{
    if (accountButton != _accountButton) {
        _accountButton = accountButton;
    }
    
    _accountButton.imageView.layer.cornerRadius = 5.0;
    _accountButton.imageView.layer.masksToBounds = YES;
    _accountButton.imageView.layer.borderWidth = 0.5;
    _accountButton.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _accountButton.frame = CGRectMake(0, 0, 30.0, 30.0);
    [_accountButton addTarget:self action:@selector(showAccountView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_accountButton];
    self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showComposeTweetView)];
}

- (void)setAccount:(User *)account
{
    if (account != _account) {
        _account = account;
    }
}


#pragma  mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserWithStatusCountTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserWithStatusCountCell"];
    
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.user = user;
    
    
    return cell;
}


#pragma mark - View Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self useFanBaDocument];
    if (self.account) {
        [self refresh];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SHARED_FANFOU_ENGINE.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // alway check fanfouEngine isAuthenticated
    if (![SHARED_FANFOU_ENGINE isAuthenticated]) {
        self.account = nil; // clear account button
        self.navigationItem.leftBarButtonItem = nil;
        self.fetchedResultsController = nil;
        [self performSegueWithIdentifier:@"needToLogin" sender:self];
    } else {
        if (!self.account) {
            [SHARED_FANFOU_ENGINE usersShowWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
                if (error) {
                    NSLog(@"users show error %@",error);
                } else {
                    NSDictionary *userInfo = response.responseJSON;
                    self.account = [User userWithInfo:userInfo inManangedObjectContext:self.managedObjectContext];
                    self.account.isUserAccount = @(YES);
                    if (!self.account.thumbnail) {
                        NSURL *url = [NSURL URLWithString:self.account.profile_image_url];
                        dispatch_queue_t imageQueue = dispatch_queue_create("image fetch", NULL);
                        dispatch_async(imageQueue, ^{
                            [UIApplication toggleNetworkActivityIndicatorVisible:YES];
                            NSData *imageData = [NSData dataWithContentsOfURL:url];
                            [UIApplication toggleNetworkActivityIndicatorVisible:NO];
                            self.account.thumbnail = imageData;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (self.account.thumbnail) {
                                    self.accountButton = [UIButton buttonWithType:UIButtonTypeCustom];
                                    [self.accountButton setImage:[UIImage imageWithData:self.account.thumbnail] forState:UIControlStateNormal];
                                    self.navigationItem.leftBarButtonItem.enabled = YES;
                                    [self setupFetchController];
                                }
                            });
                        });
                    }
                }
            }];
        } 
        
        
        
    }
}

#pragma mark - custom method

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

#pragma mark - Custom Method

#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showAccount"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setUser:)]) {
            [segue.destinationViewController performSelector:@selector(setUser:) withObject:self.account];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showStatus"]) {
        if ([sender isKindOfClass:[UserWithStatusCountTVCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            
            if (indexPath) {
                User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
                if ([segue.destinationViewController respondsToSelector:@selector(setUser:)]) {
                    [segue.destinationViewController performSelector:@selector(setUser:) withObject:user];
                }
            }
        }
    }
    
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[TweetComposeViewController class]]) {
        TweetComposeViewController *tcvc = segue.sourceViewController;
        
        if (tcvc.photoImageView.image) {
            NSData *imageData = UIImageJPEGRepresentation(tcvc.photoImageView.image, 1);
            [SHARED_FANFOU_ENGINE uploadPhoto:imageData status:tcvc.tweetTextView.text WithCompletionBlock:^(NSError *error) {
                if (error) {
                    NSLog(@"sent error");
                    [SVProgressHUD showErrorWithStatus:@"发送失败"];
                } else {
                    NSLog(@"done");
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                    AudioServicesPlaySystemSound(1016);
                }
            }];
        } else {
            [SHARED_FANFOU_ENGINE sentTweet:tcvc.tweetTextView.text withCompletionBlock:^(NSError *error) {
                if (error) {
                    NSLog(@"sent error");
                    [SVProgressHUD showErrorWithStatus:@"发送失败"];
                } else {
                    NSLog(@"done");
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                    AudioServicesPlaySystemSound(1016);
                }
            }];
        }
    }
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    
}



#pragma mark - Custom method
- (void)showAccountView
{
    [self performSegueWithIdentifier:@"showAccount" sender:self];
}

- (void)showComposeTweetView
{
    [self performSegueWithIdentifier:@"showCompose" sender:self];
}


- (void)setupAccount
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"isUserAccount == YES"];
    
    NSError *error = nil;
    NSArray *mathces = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!mathces || ([mathces count] >1)) {
        // handle error
        
        NSLog(@" no matches account error");
    } else if (![mathces count]) {
        NSLog(@" no matches ");
        
    } else {
        self.account = [mathces lastObject];
    }
    
    
    UIImage *accountButtonImage;
    if (!self.account.thumbnail) {
        accountButtonImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultThumbnail" ofType:@"png"]];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    } else {
        accountButtonImage = [UIImage imageWithData:self.account.thumbnail];
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    
    self.accountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.accountButton setImage:accountButtonImage forState:UIControlStateNormal];
}

- (void)setupFetchController
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    //                        request.predicate = [NSPredicate predicateWithFormat:@"unique_id != %@",self.account.unique_id];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}





@end
