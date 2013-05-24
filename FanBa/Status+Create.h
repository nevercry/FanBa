//
//  Status+Create.h
//  FanBa
//
//  Created by nevercry on 13-5-21.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "Status.h"

@interface Status (Create)

+ (Status *)statusWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context;


@end
