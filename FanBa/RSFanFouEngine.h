//
//  RSFanFouEngine.h
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "RSOAuthEngine.h"


@protocol RSFanFouEngineDelegate;

typedef void (^RSFanFouEngineCompletionBlock)(NSError *error);


@interface RSFanFouEngine : RSOAuthEngine

@property (readonly) RSFanFouEngineCompletionBlock OAuthCompletionBlock;
@property (assign) id <RSFanFouEngineDelegate> delegate;
@property (readonly) NSString *screenName;

- (id)initWithDelegate:(id <RSFanFouEngineDelegate>)delegate;
- (void)authenticateWithCompletionBlock:(RSFanFouEngineCompletionBlock)completionBlock;
- (void)resumeAuthenticationFlowWithURL:(NSURL *)url;
- (void)cancelAuthentication;
- (void)forgetStoredToken;
- (void)sentTweet:(NSString *)tweet withCompletionBlock:(RSFanFouEngineCompletionBlock)completionBlock;

@end

@protocol RSFanFouEngineDelegate <NSObject>

- (void)fanfouEngine:(RSFanFouEngine *)engine needsToOpenURL:(NSURL *)url;
- (void)fanfouEngine:(RSFanFouEngine *)engine statusUpdate:(NSString *)message;

@end