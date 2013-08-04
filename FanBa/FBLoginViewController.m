//
//  FBLoginViewController.m
//  FanBa
//
//  Created by nevercry on 13-5-25.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "FBLoginViewController.h"
#import "FBCoreData.h"
#import "RSFanFouEngine.h"
#import "Status.h"
#import "Photo.h"
#import "User.h"

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine

@interface FBLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noUserInfoLabel;


@end

@implementation FBLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    SHARED_FANFOU_ENGINE.delegate = self;
    self.noUserInfoLabel.text = @"饭否要求您授权「饭霸」使用您的帐户信息后才能开始使用，点击「登录」将会打开饭否的应用授权页面";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}



#pragma mark - RSFanFouEngine Delegate Methods
- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message
{
    self.navigationItem.title = message;
}



- (IBAction)loginFanfou:(UIBarButtonItem *)sender {
    [SHARED_FANFOU_ENGINE authenticateWithCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"auth error %@",error);
        } else if ([SHARED_FANFOU_ENGINE isAuthenticated]) {
            [self performSegueWithIdentifier:@"done" sender:self];
        }
    }];
}

//- (IBAction)logoutButton {
//    if (SHARED_FANFOU_ENGINE) [SHARED_FANFOU_ENGINE forgetStoredToken];
//    
//    
//    //first delete status
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    NSError *error;
//    NSArray *items = [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    NSLog(@"error is %@",error);
//    
//    
//    for (Status *managedObject in items) {
//    	[[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext deleteObject:managedObject];
//    	NSLog(@"status object deleted %@",managedObject);
//    }
//    if (![[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext save:&error]) {
//    	NSLog(@"Error deleting  - error:%@",error);
//    }
//    
//    // second delete user
//    
//    entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    items = [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    
//    for (User *usermanagedObject in items) {
//        [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext deleteObject:usermanagedObject];
//        NSLog(@"user object deleted %@",usermanagedObject);
//    }
//    if (![[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext save:&error]) {
//        NSLog(@"Error deleting - error:%@",error);
//    }
//    
//    // third delete photo
//    entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    items = [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    
//    for (Photo *photomanagedObject in items) {
//        [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext deleteObject:photomanagedObject];
//        NSLog(@"photo object deleted %@",photomanagedObject);
//    }
//    if (![[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext save:&error]) {
//        NSLog(@"Error deleting - error:%@",error);
//    }
//
//
//}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}





@end
