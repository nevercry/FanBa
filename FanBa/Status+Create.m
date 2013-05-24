//
//  Status+Create.m
//  FanBa
//
//  Created by nevercry on 13-5-21.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "Status+Create.h"
#import "RSFanFouEngine.h"
#import "User+Created.h"
#import "Photo+Created.h"


@implementation Status (Create)

+ (Status *)statusWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context
{
    Status *status = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rawid" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"rawid = %@",info[FANFOU_STATUS_RAWID]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] >1)) {
        NSLog(@"matches is nil %@",error);
    } else if (![matches count]) {
        status = [NSEntityDescription insertNewObjectForEntityForName:@"Status" inManagedObjectContext:context];
        status.unique_id = info[FANFOU_STATUS_ID];
        status.created_at = info[FANFOU_STATUS_CREATED_AT];
        status.rawid = info[FANFOU_STATUS_RAWID];
        status.text = info[FANFOU_STATUS_TEXT];
        status.source = info[FANFOU_STATUS_SOURCE];
        status.isTruncated = info[FANFOU_STATUS_TRUNCATED];
        status.in_reply_to_status_id = info[FANFOU_STATUS_IN_REPLY_TO_STATUS_ID];
        status.in_reply_to_user_id = info[FANFOU_STATUS_IN_REPLY_TO_USER_ID];
        status.in_reply_to_screen_name = info[FANFOU_STATUS_IN_REPLY_TO_SCREEN_NAME];
        status.repost_status_id = info[FANFOU_STATUS_REPOST_STATUS_ID];
        status.repost_user_id = info[FANFOU_STATUS_REPOST_USER_ID];
        status.location = info[FANFOU_STATUS_LOCATION];
        status.isFaverited = info[FANFOU_STATUS_FAVORITED];
        
        NSDictionary *userInfo = info[FANFOU_STATUS_USER];
        User *user = [User userWithInfo:userInfo inManangedObjectContext:context];
        status.whoSented = user;
        
        NSDictionary *photoInfo = info[FANFOU_STATUS_PHOTO];
        Photo *photo = [Photo photoWithInfo:photoInfo inManangedObjectContext:context];
        status.photo = photo;
        NSLog(@"status done");
    } else {
        status = [matches lastObject];
        NSLog(@"match status");
    }

    return status;
}

@end
