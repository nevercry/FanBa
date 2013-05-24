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

@interface DemoViewCDTVC ()

@end

@implementation DemoViewCDTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
    self.fanfouEngine = [[RSFanFouEngine alloc] initWithDelegate:self];    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self useFanBaDocument];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check if the user is already authenticated
    if (self.fanfouEngine.isAuthenticated) {
        self.autherSwitchButton.title = @"Signed in";
        NSLog(@"is authenticated");
    } else {
        self.autherSwitchButton.title = @"Not signed in.";
        NSLog(@"start oauth");
    }
    [self.fanfouEngine showHomeLineWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
        if (error) {
            NSLog(@"home line error %@",error);
        } else {
            if (self.fanfouEngine.responseArray && self.managedObjectContext) {
                for (NSDictionary*statusInfo in self.fanfouEngine.responseArray) {
                    [Status statusWithInfo:statusInfo inManagedObjectContext:self.managedObjectContext];
                }
            }
        }
    }];
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
    [self.fanfouEngine showHomeLineWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
            if (error) {
                NSLog(@"home line error %@",error);
            } else {
                if (self.fanfouEngine.responseArray && self.managedObjectContext) {
                    for (NSDictionary*statusInfo in self.fanfouEngine.responseArray) {
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
    [self performSegueWithIdentifier:@"setCurrentURL:" sender:url];
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
    self.autherSwitchButton.title = message;
}

#pragma mark - Custom Method

- (IBAction)unSignin:(UIBarButtonItem *)sender {
    if (self.fanfouEngine) [self.fanfouEngine forgetStoredToken];
    self.autherSwitchButton.title = @"Not signed in.";
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"error is %@",error);
    
    
    for (Status *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    	NSLog(@"status object deleted");
    }
    if (![self.managedObjectContext save:&error]) {
    	NSLog(@"Error deleting  - error:%@",error);
    }
    
    [self.fanfouEngine showHomeLineWithCompletionBlock:^(NSError *error, MKNetworkOperation *response) {
        if (error) {
            NSLog(@"home line error %@",error);
        } else {
            if (self.fanfouEngine.responseArray && self.managedObjectContext) {
                for (NSDictionary*statusInfo in self.fanfouEngine.responseArray) {
                    [Status statusWithInfo:statusInfo inManagedObjectContext:self.managedObjectContext];
                }
            }
        }
    }];
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


- (IBAction)dismissWebView:(UIStoryboardSegue *)segue
{
    if (self.fanfouEngine) [self.fanfouEngine cancelAuthentication];
}









@end
