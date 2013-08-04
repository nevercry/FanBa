//
//  User+Created.h
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "User.h"

@interface User (Created)

+ (User *)userWithInfo:(NSDictionary *)info inManangedObjectContext:(NSManagedObjectContext *)context;


@end
