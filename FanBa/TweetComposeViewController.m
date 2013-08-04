//
//  TweetComposeViewController.m
//  FanBa
//
//  Created by nevercry on 13-7-27.
//  Copyright (c) 2013年 nevercry. All rights reserved.
//

#import "TweetComposeViewController.h"

#define MAX_TEXT_LENGTH_COUNT 140


@interface TweetComposeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tweetCharCountLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sentTweetBarButton;
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (nonatomic,strong) NSData *photoData;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetCCLConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTrailConstarint;



@end

@implementation TweetComposeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.sentTweetBarButton.enabled = NO;
    self.photoImageView.hidden = YES;
    self.tweetCharCountLabel.text = [NSString stringWithFormat:@"%d",MAX_TEXT_LENGTH_COUNT - [self.tweetTextView.text length]];
    self.tweetTextView.delegate = self;
    
    
    
    
    // Listen for the keyboard to show up so we can get its height
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [self.tweetTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    // 重新计算UITextView和UILabel的位置
    
    if ([notification.name isEqualToString:UIKeyboardDidShowNotification] )
    {
       
        
        CGRect keyboardRect = [self.view convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]  fromView:nil];
        
        
        
        self.tweetCCLConstraint.constant = keyboardRect.size.height;

        
    }
}


- (void)setPhotoData:(NSData *)photoData
{
    if (photoData != _photoData) {
        _photoData = photoData;
    }
    
}




- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger textCounts = (MAX_TEXT_LENGTH_COUNT - [self.tweetTextView.text length]);
    self.tweetCharCountLabel.text = [NSString stringWithFormat:@"%d",textCounts];
    
    
    if ([self.tweetTextView.text length] <= MAX_TEXT_LENGTH_COUNT && [self.tweetTextView.text length] > 0){
        self.tweetCharCountLabel.textColor = [UIColor lightGrayColor];
        self.sentTweetBarButton.enabled = YES;
    } else if ([self.tweetTextView.text length] == 0) {
        self.tweetCharCountLabel.textColor = [UIColor lightGrayColor];
        if (self.photoImageView.image) {
            self.sentTweetBarButton.enabled = YES;
        } else {
            self.sentTweetBarButton.enabled = NO;
        }
    } else {
        self.tweetCharCountLabel.textColor = [UIColor redColor];
        self.sentTweetBarButton.enabled = NO;
    }
    
}

- (IBAction)selectPicture:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片",@"从照片库中选择", nil];
    [actionSheet showInView:self.tweetTextView];
}


#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker;
    
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc] init];
    }
    imagePicker.delegate = self;
    
    

    
    if (buttonIndex == 0) {
        // 拍摄照片
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront|UIImagePickerControllerCameraDeviceRear]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [self presentViewController:imagePicker animated:YES completion:NULL];
        } else {
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }
    } else if (buttonIndex == 1)
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.photoImageView.image = image;
    self.photoImageView.hidden = NO;
    self.sentTweetBarButton.enabled = YES;
    
    self.textViewTrailConstarint.constant = self.photoImageView.frame.size.width;
    
    
    
}





@end
