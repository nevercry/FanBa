//
//  FBAccountViewController.m
//  FanBa
//
//  Created by nevercry on 13-5-28.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "FBAccountViewController.h"
#import "FBCoreData.h"
#import "Status.h"
#import "Photo.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>

#define SHARED_FANFOU_ENGINE [FBCoreData sharedManagedDocument].fanfouEngine

@interface FBAccountViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *accountDescription;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountScreenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *accountThumbnailImageView;

@end

@implementation FBAccountViewController


- (void)setUser:(User *)user
{
    _user = user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountNameLabel.text = self.user.name;
    self.accountScreenNameLabel.text = self.user.screen_name;
    self.accountDescription.textLabel.text = self.user.user_despcription;
    NSData *imageData = self.user.thumbnail;
    UIImage *image = [UIImage imageWithData:imageData];
    self.accountThumbnailImageView.image = image;
    self.accountThumbnailImageView.layer.cornerRadius = 5.0;
    self.accountThumbnailImageView.layer.masksToBounds = YES;
    self.accountThumbnailImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.accountThumbnailImageView.layer.borderWidth = 1.0;
    
}

- (IBAction)logout
{
    if (SHARED_FANFOU_ENGINE) [SHARED_FANFOU_ENGINE forgetStoredToken];
    
    
    //first delete status
    
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
    
    
    NSError * error;
    // retrieve the store URL
    NSURL * storeURL = [[[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext lock];
    [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [[FBCoreData sharedManagedDocument].sharedDocument.managedObjectContext unlock];
    //that's it !
    
    
    
    [self performSelector:@selector(logoutDone) withObject:nil afterDelay:1.0];
}


- (void)logoutDone
{
    [self performSegueWithIdentifier:@"done" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        CGSize constraint = CGSizeMake((tableView.frame.size.width - 40.0f), 2008.0f);
        
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        
        
        NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        CGRect rect = [self.accountDescription.textLabel.text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic context:context];
        
        CGFloat height = ceil(rect.size.height);
        
        return MAX(height, 70)  ;
    } else
        return 51.0;
}




@end
