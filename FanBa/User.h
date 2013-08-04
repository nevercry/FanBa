//
//  User.h
//  FanBa
//
//  Created by nevercry on 13-7-25.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSNumber * favorites_count;
@property (nonatomic, retain) NSNumber * followers_count;
@property (nonatomic, retain) NSNumber * friends_count;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * isFollowing;
@property (nonatomic, retain) NSNumber * isNotifications;
@property (nonatomic, retain) NSNumber * isProtected;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profile_image_url;
@property (nonatomic, retain) NSString * profile_image_url_large;
@property (nonatomic, retain) NSString * screen_name;
@property (nonatomic, retain) NSNumber * statuses_count;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * user_despcription;
@property (nonatomic, retain) NSNumber * utc_offset;
@property (nonatomic, retain) NSNumber * isUserAccount;
@property (nonatomic, retain) NSSet *statuses;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addStatusesObject:(Status *)value;
- (void)removeStatusesObject:(Status *)value;
- (void)addStatuses:(NSSet *)values;
- (void)removeStatuses:(NSSet *)values;

@end
