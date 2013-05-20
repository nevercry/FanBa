//
//  RSFanFouEngine.m
//  FanBa
//
//  Created by nevercry on 13-5-20.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "RSFanFouEngine.h"


// Never share this information
#error Put your Consumer Key and Secrect here, then remove this error
#define FA_CONSUMER_KEY @""
#define FA_CONSUMER_SECRET @""

// This will be called after the user authorizes your app
#define FA_CALLBACK_URL @"rsfanfouengine://auth_token"

// Default fanfou hostname and paths and apihostname
#define FA_HOSTNAME @"fanfou.com"
#define FA_REQUEST_TOKEN @"oauth/request_token"
#define FA_ACCESS_TOKEN @"oauth/access_token"
#define FA_STATUS_UPDATE @"statuses/update.json"
#define FA_API_HOSTNAME @"http://api.fanfou.com/"

// URL to redirect the user for authentication
#define FA_AUTHORIZE(__TOKEN__,__CALLBACKURL__) [NSString stringWithFormat:@"http://fanfou.com/oauth/authorize?oauth_token=%@&oauth_callback=%@",__TOKEN__,__CALLBACKURL__]


@interface RSFanFouEngine ()

@property (readwrite) RSFanFouEngineCompletionBlock OAuthCompletionBlock;
@property (readwrite) NSString *screenName;



- (void)removeOAuthTokenFromKeychain;
- (void)storeOAuthTokenInKeychain;
- (void)retrieveOAuthTokenFromKeychain;

@end



@implementation RSFanFouEngine


#pragma mark - Initialization

- (id)initWithDelegate:(id<RSFanFouEngineDelegate>)delegate
{
    self = [super initWithHostName:FA_HOSTNAME
                customHeaderFields:nil
                   signatureMethod:RSOAuthHMAC_SHA1 consumerKey:FA_CONSUMER_KEY
                    consumerSecret:FA_CONSUMER_SECRET
                       callbackURL:FA_CALLBACK_URL];
    
    if (self) {
        self.OAuthCompletionBlock = nil;
        self.screenName = nil;
        self.delegate = delegate;
        
        // Retrieve OAuth access token (if previously stored)
        [self retrieveOAuthTokenFromKeychain];
    }
    
    return self;
}

#pragma mark - OAuth Access Token store/retrieve

- (void)removeOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    // If there's a token stored for this user, delete it
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemDelete(query);
    CFRelease(query);
}


- (void)storeOAuthTokenInKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnAttributes,
                                          nil];
    
    CFTypeRef resData = NULL;
    
    // If there's a token stored for this user, delete it first
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef) keychainQuery;
    SecItemDelete(query);
    CFRelease(query);
    
    
    // Build the token dictionary
    NSMutableDictionary *tokenDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            self.token, @"oauth_token",
                                            self.tokenSecret, @"oauth_token_secret",
                                            self.screenName, @"screen_name",
                                            nil];
    
    
    // Add the token dictionary to the query
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:tokenDictionary] forKey:(__bridge_transfer NSString *)kSecValueData];
    
    // Add the token data to the keychain
    // Even if we never use resData, replacing with NULL in the call throws EXC_BAD_ACCESS
    query = (__bridge_retained CFDictionaryRef)keychainQuery;
    SecItemAdd(query, (CFTypeRef *) &resData);
    CFRelease(query);
}

- (void)retrieveOAuthTokenFromKeychain
{
    // Build the keychain query
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          (__bridge_transfer NSString *)kSecClassGenericPassword, (__bridge_transfer NSString *)kSecClass,
                                          self.consumerKey, kSecAttrService,
                                          self.consumerKey, kSecAttrAccount,
                                          kCFBooleanTrue, kSecReturnData,
                                          kSecMatchLimitOne, kSecMatchLimit,
                                          nil];
    
    // Get the token data from the keychain
    CFTypeRef resData = NULL;
    
    // Get the token dictionary from the keychain
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef)keychainQuery;
    
    if (SecItemCopyMatching(query, (CFTypeRef *)&resData) == noErr)
    {
        NSData *resultData = (__bridge_transfer NSData *)resData;
        
        if (resultData)
        {
            NSMutableDictionary *tokenDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
            
            if (tokenDictionary) {
                [self setAccessToken:[tokenDictionary objectForKey:@"oauth_token"]
                              secret:[tokenDictionary objectForKey:@"oauth_token_secret"]];
                
                self.screenName = [tokenDictionary objectForKey:@"screen_name"];
            }
        }
        
    }
    
}


#pragma mark - OAuth Authentication Flow

- (void)authenticateWithCompletionBlock:(RSFanFouEngineCompletionBlock)completionBlock
{
    // Store the Completion Block to call after Authenticated
    self.OAuthCompletionBlock = [completionBlock copy];
    
    // First we reset the OAuth token, so we don't send previous tokens in the request
    [self resetOAuthToken];
    
    // OAuth Step 1 - Obtain a request token
    MKNetworkOperation *op = [self operationWithPath:FA_REQUEST_TOKEN
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the request token with the return data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthRequestToken];
        
        // OAuth Step 2 - Redirect user to authorization page
        [self.delegate fanfouEngine:self statusUpdate:@"Waiting For user authorization..."];
        NSURL *url = [NSURL URLWithString:FA_AUTHORIZE(self.token, FA_CALLBACK_URL)];
        [self.delegate fanfouEngine:self needsToOpenURL:url];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error);
        self.OAuthCompletionBlock = nil;
    }];
    
    [self.delegate fanfouEngine:self statusUpdate:@"Requesting Tokens..."];
    [self enqueueSignedOperation:op];
}

- (void)resumeAuthenticationFlowWithURL:(NSURL *)url
{
    // Fill the request token with data returned in the callback URL
    [self fillTokenWithResponseBody:url.query type:RSOAuthRequestToken];
    
    // OAuth Step 3 - Exchange the request token with an access token
    MKNetworkOperation *op = [self operationWithPath:FA_ACCESS_TOKEN
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Fill the access token with the returned data
        [self fillTokenWithResponseBody:[completedOperation responseString] type:RSOAuthAccessToken];
        
        // Retrieve the user's screen name
        self.screenName = [self customValueForKey:@"screen_name"];
        
        // Store the OAuth access token
        [self storeOAuthTokenInKeychain];
        
        // Finished, return to previous method
        if (self.OAuthCompletionBlock) self.OAuthCompletionBlock(nil);
        self.OAuthCompletionBlock = nil;
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (self.OAuthCompletionBlock) self.OAuthCompletionBlock(error);
        self.OAuthCompletionBlock = nil;
    }];
    
    [self.delegate fanfouEngine:self statusUpdate:@"Authenticating..."];
    [self enqueueSignedOperation:op];
}

- (void)cancelAuthentication
{
    NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:@"Authentication cancelled.", NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"com.sharpcube.RSFanFouEngine.ErrorDomain" code:401 userInfo:ui];
    
    if (self.OAuthCompletionBlock) self.OAuthCompletionBlock(error);
    self.OAuthCompletionBlock = nil;
}

- (void)forgetStoredToken
{
    [self removeOAuthTokenFromKeychain];
    
    [self resetOAuthToken];
    self.screenName = nil;
}

#pragma mark - Public Methods

- (void)sentTweet:(NSString *)tweet withCompletionBlock:(RSFanFouEngineCompletionBlock)completionBlock
{
    if (!self.isAuthenticated) {
        [self authenticateWithCompletionBlock:^(NSError *error) {
            if (error) {
                // Authentication failed, return the error
                completionBlock(error);
            } else {
                // Authentication succeeded, call this method again
                [self sentTweet:tweet withCompletionBlock:completionBlock];
            }
        }];
        
        // This method will be called again once the authentication completes
        return;
    }
    
    // Fill the post body with the tweet
    NSMutableDictionary *postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       tweet, @"status",
                                       nil];
    
    // add fanfou version for send tweet 
    MKNetworkOperation *op = [self operationWithURLString:[NSString stringWithFormat:@"%@%@",FA_API_HOSTNAME,FA_STATUS_UPDATE]
                                              params:postParams
                                          httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        completionBlock(nil);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        completionBlock(error);
    }];
    
    [self.delegate fanfouEngine:self statusUpdate:@"Sending tweet..."];
    [self enqueueSignedOperation:op];
    
}


@end
