//
//  FBCoreData.h
//  FanBa
//
//  Created by nevercry on 13-5-21.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSFanFouEngine.h"

@interface FBCoreData : NSObject

@property (readonly,strong,nonatomic) UIManagedDocument *sharedDocument;
@property (nonatomic,strong) RSFanFouEngine *fanfouEngine;

+ (FBCoreData *)sharedManagedDocument;

@end
