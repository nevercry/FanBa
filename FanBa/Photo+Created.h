//
//  Photo+Created.h
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "Photo.h"

@interface Photo (Created)

+ (Photo *)photoWithInfo:(NSDictionary *)info inManangedObjectContext:(NSManagedObjectContext *)context;

@end
