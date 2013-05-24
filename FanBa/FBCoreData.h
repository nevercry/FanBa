//
//  FBCoreData.h
//  FanBa
//
//  Created by nevercry on 13-5-21.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBCoreData : NSObject

@property (readonly,strong,nonatomic) UIManagedDocument *sharedDocument;

+ (FBCoreData *)sharedManagedDocument;

@end
