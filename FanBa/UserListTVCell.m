//
//  UserListTVCell.m
//  FanBa
//
//  Created by nevercry on 13-7-26.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UserListTVCell.h"
#import "RSFanFouEngine.h"
#import <QuartzCore/QuartzCore.h>


@interface UserListTVCell ()


@end

@implementation UserListTVCell

- (void)setUser:(NSDictionary *)user
{
    if (user != _user) {
        _user = user;
    }
    
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:1];
    
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 0.5;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaultThumbnail" ofType:@"png"]];
        
    
    
    
    
    UILabel *userNameLabel = (UILabel *)[self.contentView viewWithTag:2];
    userNameLabel.text = _user[FANFOU_USER_NAME];
    
    
    UILabel *userIDLabel = (UILabel *)[self.contentView viewWithTag:3];
    userIDLabel.text = _user[FANFOU_USER_ID];
    
    
    [imageView setNeedsDisplay];
    [userNameLabel setNeedsDisplay];
    [userIDLabel setNeedsDisplay];
};

- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    if (thumbnailImage != _thumbnailImage) {
        _thumbnailImage = thumbnailImage;
    }
    
    UIImageView *imageView = (UIImageView *)[self.contentView viewWithTag:1];
    imageView.image = _thumbnailImage;
    
    [imageView setNeedsDisplay];
}



@end
