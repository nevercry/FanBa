//
//  User+Created.m
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "User+Created.h"
#import "RSFanFouEngine.h"

@implementation User (Created)

+ (User *)userWithInfo:(NSDictionary *)info inManangedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@",[info[FANFOU_USER_ID] description]];
    
    NSError *error = nil;
    NSArray *mathces = [context executeFetchRequest:request error:&error];
    
    if (!mathces || ([mathces count] >1)) {
        // handle error
    } else if (![mathces count]) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.unique_id = info[FANFOU_USER_ID];
        user.name = info[FANFOU_USER_NAME];
        user.screen_name = info[FANFOU_USER_SCREEN_NAME];
        user.location = info[FANFOU_USER_LOCATION];
        user.gender = info[FANFOU_USER_GENDER];
        user.birthday = info[FANFOU_USER_BIRTHDAY];
        user.user_despcription = info[FANFOU_USER_DESCRIPTION];
        user.profile_image_url = info[FANFOU_USER_PROFILE_IMAGE_URL];
        user.profile_image_url_large = info[FANFOU_USER_PROFILE_IMAGE_URL_LARGE];
        user.url = info[FANFOU_USER_URL];
        user.isProtected = info[FANFOU_USER_PROTECTED];
        user.followers_count = info[FANFOU_USER_FAVOURITES_COUNT];
        user.friends_count = info[FANFOU_USER_FRIENDS_COUNT];
        user.favorites_count = info[FANFOU_USER_FAVOURITES_COUNT];
        user.statuses_count = info[FANFOU_USER_STATUSES_COUNT];
        user.isFollowing = info[FANFOU_USER_FOLLOWING];
        user.isNotifications = info[FANFOU_USER_NOTIFICATIONS];
        user.created_at = info[FANFOU_USER_CREATED_AT];
        user.utc_offset = info[FANFOU_USER_UTC_OFFSET];
        user.isUserAccount = @(NO);
    } else {
        user = [mathces lastObject];
    }
    
    return user;
}




@end
