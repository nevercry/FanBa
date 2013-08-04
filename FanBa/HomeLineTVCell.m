//
//  HomeLineTVCell.m
//  FanBa
//
//  Created by nevercry on 13-8-1.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "HomeLineTVCell.h"
#import "Status.h"
#import "User.h"
#import "TTTAttributedLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+NetworkActivity.h"

#define DATE_LABEL_ORGIN_X (self.bounds.size.width - (70+10))
#define DATE_LABEL_ORGIN_Y 10
#define DATE_LABEL_SIZE_WIDTH 70
#define DATE_LABEL_SIZE_HEIGHT 18

@implementation HomeLineTVCell


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
    
    
    [imageView setNeedsDisplay];
    [userNameLabel setNeedsDisplay];
}


- (void)setStatus:(Status *)status
{
    if (status != _status) {
        _status = status;
    }
    
    
    
    TTTAttributedLabel *statusLabel = (TTTAttributedLabel *)[self.contentView viewWithTag:3];
    
    statusLabel.layer.shouldRasterize = YES;
    statusLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    statusLabel.numberOfLines = 0;
    statusLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(__bridge NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    statusLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    
    statusLabel.highlightedTextColor = [UIColor whiteColor];
    statusLabel.shadowColor = [UIColor colorWithWhite:0.87 alpha:1.0];
    statusLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    statusLabel.highlightedShadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
    statusLabel.highlightedShadowOffset = CGSizeMake(0.0f, -1.0f);
    statusLabel.highlightedShadowRadius = 1;
    statusLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    statusLabel.userInteractionEnabled = YES;
    statusLabel.lineBreakMode = NSLineBreakByCharWrapping;
    statusLabel.leading = 1;
    
    
    NSString *htmlToTextString = [self htmlToText:_status.text];
    
    
    
    [statusLabel setText:htmlToTextString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        
        
        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
        
        
        NSString *htmlPattern = @"<a href=\"([^\"]+)\"[^>]*>([^<]+)</a>";
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:htmlPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger matchCounts = [regexp numberOfMatchesInString:[mutableAttributedString string] options:NSMatchingReportCompletion range:stringRange];
        
        if (matchCounts) {
            for (int i = 0; i < matchCounts; i++) {
                NSTextCheckingResult *textResult = [regexp firstMatchInString:[mutableAttributedString string] options:0 range:NSMakeRange(0, [mutableAttributedString length])];
                NSString *matchString = [[mutableAttributedString string] substringWithRange:[textResult rangeAtIndex:2]];
                
                [mutableAttributedString replaceCharactersInRange:textResult.range withString:matchString];
                
                NSString *preFixStr = [[mutableAttributedString string] substringWithRange:NSMakeRange(textResult.range.location - 1, 1)];
                NSRange replacedMatchStringRange = NSMakeRange(textResult.range.location, [matchString length]);
                
                if ([preFixStr isEqualToString:@"@"]) {
                    UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:16];
                    
                    NSRange accountNameRange = NSMakeRange(replacedMatchStringRange.location - 1, replacedMatchStringRange.length + 1);
                    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
                    if (boldFont) {
                        [mutableAttributedString removeAttribute:(__bridge NSString *)kCTFontAttributeName range:accountNameRange];
                        [mutableAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:accountNameRange];
                        CFRelease(boldFont);
                        
                        [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:accountNameRange];
                        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor colorWithRed:57.0/255.0 green:83.0/255.0  blue:128.0/255.0 alpha:1.0] CGColor] range:accountNameRange];
                        
                    }
                } else if ([preFixStr isEqualToString:@"#"]) {
                    NSRange hashTagRange = NSMakeRange(replacedMatchStringRange.location - 1, replacedMatchStringRange.length + 2);
                    [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:hashTagRange];
                    [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor grayColor] CGColor] range:hashTagRange];
                } else {
                    [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:replacedMatchStringRange];
                    [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithRed:57.0/255.0 green:83.0/255.0 blue:128.0/255.0 alpha:1.0] range:replacedMatchStringRange];
                }
                
                
            }
        }
        
        return mutableAttributedString;
    }];
    
    
    NSMutableString *testString = [NSMutableString stringWithString:[self htmlToText:status.text]];
    
    NSString *htmlPattern = @"<a href=\"([^\"]+)\"[^>]*>([^<]+)</a>";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:htmlPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger matchCounts = [regexp numberOfMatchesInString:testString options:NSMatchingReportCompletion range:NSMakeRange(0,[testString length])];
    
    if (matchCounts) {
        for (int i = 0; i < matchCounts; i++) {
            NSTextCheckingResult *textResult = [regexp firstMatchInString:testString options:0 range:NSMakeRange(0, [testString length])];
            NSString *matchStringURLString = [testString substringWithRange:[textResult rangeAtIndex:1]];
            NSString *matchString = [testString substringWithRange:[textResult rangeAtIndex:2]];
            
            [testString replaceCharactersInRange:textResult.range withString:matchString];
            
            
            NSString *preFixStr = [testString substringWithRange:NSMakeRange(textResult.range.location - 1, 1)];
            NSRange replacedMatchStringRange = NSMakeRange(textResult.range.location, [matchString length]);
            
            if ([preFixStr isEqualToString:@"@"]) {
                
                
                NSRange accountNameRange = NSMakeRange(replacedMatchStringRange.location - 1, replacedMatchStringRange.length + 1);
                
                NSURL *url = [NSURL URLWithString:[matchStringURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                NSString *accountURLStr = [NSString stringWithFormat:@"fbaccount://account.com/%@/",[url lastPathComponent]];
                
                NSURL *accountURL = [NSURL URLWithString:[accountURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                [statusLabel addLinkToURL:accountURL withRange:accountNameRange];
                
            } else if ([preFixStr isEqualToString:@"#"]) {
                
            } else {
                // is URL
                NSRange urlRange = NSMakeRange(replacedMatchStringRange.location, replacedMatchStringRange.length);
                NSURL *url = [NSURL URLWithString:matchStringURLString];
                [statusLabel addLinkToURL:url withRange:urlRange];
            }
        }
    }
    
    
    
    // Date convert ---
    
    [self updateTimeLabel];
    
    
    
    
    
    
    
    
    // --- Date convert
    
    
    
    
    

    [statusLabel setNeedsDisplay];
}



- (NSString *)htmlToText:(NSString *)htmlString
{
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@"&"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@""""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&#039;"  withString:@"'"];
    
    // Extras
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<3" withString:@"♥"];
    
    // normalize and separate newline from other words
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" \n "];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@" \n "];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"\\n" withString:@" \n "];
    
    return htmlString;
}

- (void)updateTimeLabel
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM d H:m:s Z yyyy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSDate *statusDate = [dateFormatter dateFromString:self.status.created_at];
    
    
    CGRect labelRect = CGRectMake(DATE_LABEL_ORGIN_X,DATE_LABEL_ORGIN_Y,DATE_LABEL_SIZE_WIDTH,DATE_LABEL_SIZE_HEIGHT);
    
    if (!self.dateLabel) {
        self.dateLabel = [[UILabel alloc] initWithFrame:labelRect];
        [self.contentView addSubview:self.dateLabel];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
        self.dateLabel.font = [UIFont systemFontOfSize:10];
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.backgroundColor = self.contentView.backgroundColor;
        self.dateLabel.opaque = NO;
        self.dateLabel.textAlignment = NSTextAlignmentRight;
    } else {
        self.dateLabel.frame = labelRect;
    }
    
    
    
    
    NSInteger dateInterval = ABS([statusDate timeIntervalSinceNow]);
    
    
    NSString *dateStr;
    
    if (dateInterval/(60*60*24) >= 1) {
        dateStr = [NSString stringWithFormat:@"%d天",(dateInterval/(60*60*24))];
    } else {
        if (dateInterval/(60*60) >= 1 ) {
            dateStr = [NSString stringWithFormat:@"%d时",dateInterval/(60*60)];
        } else {
            if (dateInterval/60 >= 1 ) {
                dateStr = [NSString stringWithFormat:@"%d分",dateInterval/60];
            } else {
                dateStr = @"刚刚";
            }
        }
    }
    
    self.dateLabel.text = dateStr;
    
}


- (void) update:(NSTimer *) timer
{
    [self updateTimeLabel];
}

@end
