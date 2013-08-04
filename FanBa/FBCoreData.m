//
//  FBCoreData.m
//  FanBa
//
//  Created by nevercry on 13-5-21.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "FBCoreData.h"

@interface FBCoreData()

@property (readwrite,strong,nonatomic) UIManagedDocument *sharedDocument;


@end

@implementation FBCoreData

+ (FBCoreData *)sharedManagedDocument
{
    __strong static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FBCoreData alloc] init];
    });
    
    return _sharedInstance;
}

- (UIManagedDocument *)sharedDocument
{
    if (!_sharedDocument) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"FanBa Document"];
        _sharedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    return _sharedDocument;
}

- (RSFanFouEngine *)fanfouEngine
{
    if (!_fanfouEngine) {
        _fanfouEngine = [[RSFanFouEngine alloc] initWithDelegate:nil];
    }
    
    return _fanfouEngine;
}

@end
