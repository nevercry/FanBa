//
//  DemoViewCDTVC.m
//  FanBa
//
//  Created by nevercry on 13-5-24.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "DemoViewCDTVC.h"
#import "FBCoreData.h"
#import "Status+Create.h"
#import "WebViewController.h"
#import "User+Created.h"
#import "Photo+Created.h"
#import <QuartzCore/QuartzCore.h>

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine

@interface DemoViewCDTVC ()
@property (nonatomic,strong) User *account;



@end

@implementation DemoViewCDTVC


- (void)setAccount:(User *)account
{
    _account = account;
    NSURL *url = [NSURL URLWithString:account.profile_image_url];
    dispatch_queue_t imageQueue = dispatch_queue_create("image fetch", NULL);
    dispatch_async(imageQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        _account.thumbnail = imageData;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_account.thumbnail) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *thumbnailImage = [UIImage imageWithData:_account.thumbnail];
                
                [button setImage:thumbnailImage forState:UIControlStateNormal];
                button.imageView.layer.cornerRadius = 5.0;
                button.imageView.layer.masksToBounds = YES;
                button.imageView.layer.borderWidth = 0.5;
                button.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                
                
                button.frame = CGRectMake(0, 0, 30, 30);
                [button addTarget:self action:@selector(showAccountView) forControlEvents:UIControlEventTouchUpInside];
                
                
                NSLog(@"self account is %@",_account);
                
                
                UIBarButtonItem *accountBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
                accountBarButton.style = UIBarButtonItemStyleBordered;
                self.navigationItem.leftBarButtonItem = accountBarButton;
            }
        });
    });
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self useFanBaDocument];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    SHARED_FANFOU_ENGINE.delegate = self;
    // alway check fanfouEngine isAuthenticated
    if (![SHARED_FANFOU_ENGINE isAuthenticated]) {
        self.fetchedResultsController = nil; // clear fetched Results
        self.account = nil; // clear account button
        self.navigationItem.leftBarButtonItem = nil;
        [self performSegueWithIdentifier:@"needToLogin" sender:self];
        
    } else {
        [self refresh];
        if (!self.account) {
            [SHARED_FANFOU_ENGINE usersShowWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
                if (error) {
                    NSLog(@"users show error %@",error);
                } else {
                    NSDictionary *userInfo = response.responseJSON;
                    self.account = [User userWithInfo:userInfo inManangedObjectContext:self.managedObjectContext];
                }
            }];
        }
    }
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

#pragma mark - Custom Method

#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setCurrentURL:"]) {
        WebViewController *vc = (WebViewController *)segue.destinationViewController;
        if ([vc respondsToSelector:@selector(setCurrentURL:)]) {
            [vc performSelector:@selector(setCurrentURL:) withObject:sender];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showAccount"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setUser:)]) {
            [segue.destinationViewController performSelector:@selector(setUser:) withObject:self.account];
        }
    }
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    
}


- (void)showAccountView
{
    [self performSegueWithIdentifier:@"showAccount" sender:self];
}




@end
