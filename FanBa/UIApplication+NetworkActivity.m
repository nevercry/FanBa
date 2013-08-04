//
//  UIApplication+NetworkActivity.m
//  SPoT
//
//  Created by nevercry on 13-4-19.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "UIApplication+NetworkActivity.h"

@implementation UIApplication (NetworkActivity)

+ (void)toggleNetworkActivityIndicatorVisible:(BOOL)visible
{
    static int activityCount = 0;
    
    @synchronized (self) {
        visible ? activityCount++ : activityCount--;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = activityCount > 0;
    } 
}


@end
