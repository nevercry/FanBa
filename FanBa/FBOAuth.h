//
//  FBOAuth.h
//  FanBa
//
//  Created by nevercry on 13-5-12.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBOAuth : NSObject

#define kDMPersistentData_ConsumerKey               @"consumer_key"
#define kDMPersistentData_ConsumerSecret            @"consumer_secret"

#define kDMPersistentData_AuthToken                 @"auth_token"
#define kDMPersistentData_AuthTokenSecret           @"auth_token_secret"
#define kDMPersistentData_AuthTokenIsAuthorized     @"auth_token_authorized"

@property (nonatomic) BOOL oauth_token_authorized;
@property (nonatomic,strong) NSString *oauth_token;
@property (nonatomic,strong) NSString *oauth_token_secret;
@property (nonatomic,strong) NSString *oauth_consumer_key;
@property (nonatomic,strong) NSString *oauth_consumer_secret;

- (id)init;

- (id)initWithPersistentData:(NSDictionary *) persistentData;

// You initialize the object with your app (consumer) credentials.
- (id) initWithConsumerKey:(NSString *)aConsumerKey andConsumerSecret:(NSString *)aConsumerSecret;

// This is really the only critical oAuth method you need.
- (NSString *) oAuthHeaderForMethod:(NSString *)method andUrl:(NSString *)url andParams:(NSDictionary *)params;

// Child classes need this method during initial authorization phase. No need to call during real-life use.
- (NSString *) oAuthHeaderForMethod:(NSString *)method andUrl:(NSString *)url andParams:(NSDictionary *)params
					 andTokenSecret:(NSString *)token_secret;

// If you detect a login state inconsistency in your app, use this to reset the context back to default,
// not-logged-in state.
- (void) resetState;

- (NSDictionary *) sessionPersistentData;
- (void) loadPersistentData:(NSDictionary *) persistentDict;


@end
