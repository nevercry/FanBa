//
//  Photo+Created.m
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "Photo+Created.h"
#import "RSFanFouEngine.h"

@implementation Photo (Created)

+ (Photo *)photoWithInfo:(NSDictionary *)info inManangedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"imageurl" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"imageurl = %@",[info[FANFOU_PHOTO_IMAGEURL] description]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] >1)) {
        // handle error
    } else if (![matches count]) {
        photo.imageurl = info[FANFOU_PHOTO_IMAGEURL];
        photo.thumburl = info[FANFOU_PHOTO_THUMBURL];
        photo.largeurl = info[FANFOU_PHOTO_LARGEURL];
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}

@end
