//
//  RSFanFouEngine.h
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "RSOAuthEngine.h"

#define FANFOU_STATUS_CREATED_AT  @"created_at"
#define FANFOU_STATUS_ID          @"id"
#define FANFOU_STATUS_RAWID       @"rawid"
#define FANFOU_STATUS_TEXT        @"text"
#define FANFOU_STATUS_SOURCE      @"source"
#define FANFOU_STATUS_TRUNCATED   @"truncated"
#define FANFOU_STATUS_IN_REPLY_TO_STATUS_ID   @"in_reply_to_status_id"
#define FANFOU_STATUS_IN_REPLY_TO_USER_ID     @"in_reply_to_user_id"
#define FANFOU_STATUS_IN_REPLY_TO_SCREEN_NAME  @"in_reply_to_screen_name"
#define FANFOU_STATUS_REPOST_STATUS_ID        @"repost_status_id"
#define FANFOU_STATUS_REPOST_STATUS           @"repost_status"
#define FANFOU_STATUS_REPOST_USER_ID          @"repost_user_id"
#define FANFOU_STATUS_LOCATION    @"location"
#define FANFOU_STATUS_FAVORITED   @"favorited"
#define FANFOU_STATUS_USER        @"user"
#define FANFOU_STATUS_PHOTO       @"photo"

#define FANFOU_USER_ID            @"id"
#define FANFOU_USER_NAME          @"name"
#define FANFOU_USER_SCREEN_NAME   @"screen_name"
#define FANFOU_USER_LOCATION      @"location"
#define FANFOU_USER_GENDER        @"gender"
#define FANFOU_USER_BIRTHDAY      @"birthday"
#define FANFOU_USER_DESCRIPTION    @"description"
#define FANFOU_USER_PROFILE_IMAGE_URL         @"profile_image_url"
#define FANFOU_USER_PROFILE_IMAGE_URL_LARGE   @"profile_image_url_large"
#define FANFOU_USER_URL           @"url"
#define FANFOU_USER_PROTECTED     @"protected"
#define FANFOU_USER_FOLLOWERS_COUNT           @"followers_count"
#define FANFOU_USER_FRIENDS_COUNT             @"friends_count"
#define FANFOU_USER_FAVOURITES_COUNT          @"favourites_count"
#define FANFOU_USER_STATUSES_COUNT            @"statuses_count"
#define FANFOU_USER_FOLLOWING                 @"following"
#define FANFOU_USER_NOTIFICATIONS              @"notifications"
#define FANFOU_USER_CREATED_AT    @"created_at"
#define FANFOU_USER_UTC_OFFSET    @"utc_offset"
#define FANFOU_USER_STATUS        @"status"


#define FANFOU_PHOTO_IMAGEURL    @"imageurl"
#define FANFOU_PHOTO_THUMBURL    @"thumburl"
#define FANFOU_PHOTO_LARGEURL    @"largeurl"


@protocol RSFanFouEngineDelegate;

typedef void (^RSFanFouEngineCompletionBlock)(NSError *error);

// add a new block with respones for home line
typedef void (^RSFanFouEngineCompletionBlockWithRespones) (NSError *error,MKNetworkOperation *response);


@interface RSFanFouEngine : RSOAuthEngine

@property (readonly) RSFanFouEngineCompletionBlock OAuthCompletionBlock;
@property (assign) id <RSFanFouEngineDelegate> delegate;
@property (readonly) NSString *screenName;

//  add a new property for status
@property (readonly) NSArray *responseArray;

- (id)initWithDelegate:(id <RSFanFouEngineDelegate>)delegate;
- (void)authenticateWithCompletionBlock:(RSFanFouEngineCompletionBlock)completionBlock;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (void)forgetStoredToken;
- (void)sentTweet:(NSString *)tweet withCompletionBlock:(RSFanFouEngineCompletionBlock)completionBlock;
- (void)showHomeLineWithCompletionBlock:(RSFanFouEngineCompletionBlockWithRespones)completionBlock;

@end

@protocol RSFanFouEngineDelegate <NSObject>

- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message;

@end