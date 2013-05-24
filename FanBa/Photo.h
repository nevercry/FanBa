//
//  Photo.h
//  FanBa
//
//  Created by nevercry on 13-5-23.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Status;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageurl;
@property (nonatomic, retain) NSString * largeurl;
@property (nonatomic, retain) NSString * thumburl;
@property (nonatomic, retain) Status *inStatus;

@end
