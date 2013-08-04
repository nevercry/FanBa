//
//  TweetComposeViewController.h
//  FanBa
//
//  Created by nevercry on 13-7-27.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetComposeViewController : UIViewController<UITextViewDelegate,UITextInputTraits,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
