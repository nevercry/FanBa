//
//  Status.h
//  FanBa
//
//  Created by nevercry on 13-7-25.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, User;

@interface Status : NSManagedObject

@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * in_reply_to_screen_name;
@property (nonatomic, retain) NSString * in_reply_to_status_id;
@property (nonatomic, retain) NSString * in_reply_to_user_id;
@property (nonatomic, retain) NSNumber * isFaverited;
@property (nonatomic, retain) NSNumber * isTruncated;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * rawid;
@property (nonatomic, retain) NSString * repost_status_id;
@property (nonatomic, retain) NSString * repost_user_id;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) User *whoSent;

@end
