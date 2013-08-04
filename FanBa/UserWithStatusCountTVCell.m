//
//  UserWithStatusCountTVCell.m
//  FanBa
//
//  Created by nevercry on 13-5-31.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UserWithStatusCountTVCell.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "UIApplication+NetworkActivity.h"

@implementation UserWithStatusCountTVCell

- (void)setUser:(User *)user
{
    if (user != _user) {
        _user = user;
    }
    
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:1];
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 0.5;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    if (!_user.thumbnail) {
        NSString *defaultThumbnailPath = [[NSBundle mainBundle] pathForResource:@"defaultThumbnail" ofType:@"png"];
        imageView.image = [UIImage imageWithContentsOfFile:defaultThumbnailPath];
        
        
        NSURL *url = [NSURL URLWithString:_user.profile_image_url];
        
        
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image Fetch", NULL);
        dispatch_async(imageFetchQ, ^{
            [UIApplication toggleNetworkActivityIndicatorVisible:YES];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            [UIApplication toggleNetworkActivityIndicatorVisible:NO];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageData) {
                    _user.thumbnail = imageData;
                    imageView.image = [UIImage imageWithData:_user.thumbnail];
                    [imageView setNeedsDisplay];
                }
            });
        });
    } else {
        imageView.image = [UIImage imageWithData:_user.thumbnail];
    }
    
    
    
    UILabel *userNameLabel = (UILabel *)[self.contentView viewWithTag:2];
    userNameLabel.text = _user.name;
    
    UILabel *statusCountLabel = (UILabel *)[self.contentView viewWithTag:3];
    statusCountLabel.text = [NSString stringWithFormat:@"%d",[_user.statuses count]];
    
    [imageView setNeedsDisplay];
    [userNameLabel setNeedsDisplay];
    [statusCountLabel setNeedsDisplay];
    
}


@end
