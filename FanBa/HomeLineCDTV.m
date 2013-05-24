//
//  HomeLineCDTV.m
//  FanBa
//
//  Created by nevercry on 13-5-22.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "HomeLineCDTV.h"
#import "Status.h"
#import "User.h"

@interface HomeLineCDTV ()

@end

@implementation HomeLineCDTV

#pragma mark - Properties
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Status"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"rawid" ascending:NO]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Status"];
    Status *status = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = status.whoSented.screen_name;
    cell.detailTextLabel.text = status.text;
    
    return cell;
}


@end
