//
//  CameraPickerViewManager.m
//  Version 0.1
//  Created by Manish Rathi on 3.9.13.
//
// Copyright (c) 2013 Manish Rathi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CameraPickerViewManager.h"
#define kMaxVideoCaptureDuration 10
@interface CameraPickerViewManager()<UIActionSheetDelegate>
@property (strong,nonatomic)UIImagePickerController *imagePicker;
@end
@implementation CameraPickerViewManager
@synthesize title,cameraPopover,imagePicker,successCallback,failureCallback,delegate;

-(void)showImagePickerWithDelegate:(id)VCdelegate onSuccess:(CameraPickerViewSuccessBlock)success onFailureOrCancel:(CameraPickerViewCancelBlock)cancelBlock{
    
    
    if (self.title==nil) {
        //@Manish TODO: need to change title here
        self.title = nil;
    }
    self.successCallback = success;
    self.failureCallback = cancelBlock;
    self.delegate = VCdelegate;
    
    if ([self.cameraPopover isPopoverVisible]) {
        [self.cameraPopover dismissPopoverAnimated:YES];
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        /*
         * Ideally there should be an alert saying this device doesn'r supports camera.
         * For testing in simulator I am showing Photo-Library
         */
        [self openPhotoLibrary];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:self.title message:nil delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Photo",@"Take Video",@"Open Photo-Gallery",nil];
        [alert show];
    }
}

#pragma mark - Take Photo
-(void)takePhoto{
    if (self.imagePicker==nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
    }
    self.imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.imagePicker setShowsCameraControls:YES];
    
    [self.delegate presentModalViewController:self.imagePicker animated:YES];
}

#pragma mark - Take Video
-(void)takeVideo{
    if (self.imagePicker==nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
    }
    self.imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePicker.videoMaximumDuration =kMaxVideoCaptureDuration;
//@Manish You might need to add the framework for kUTTypeMovie constant, If any Error.
    self.imagePicker.mediaTypes =[NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    self.imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.imagePicker setShowsCameraControls:YES];
    
    [self.delegate presentModalViewController:self.imagePicker animated:YES];
}

#pragma mark - OPEN Photo-Library
-(void)openPhotoLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary])
    {
        if (self.imagePicker==nil) {
            self.imagePicker =[[UIImagePickerController alloc] init];//[UIImagePickerController new];
            self.imagePicker.delegate = self;
            self.imagePicker.navigationBarHidden = YES;
            self.imagePicker.toolbarHidden = YES;
            self.imagePicker.wantsFullScreenLayout = YES;
        }
        self.imagePicker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes =[NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.cameraPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:self.imagePicker];
            self.cameraPopover.delegate =self.delegate;
            CGRect rect = CGRectMake([self.delegate view].frame.size.width/2,[self.delegate view].frame.size.height/2, 1, 1);
            [self.cameraPopover presentPopoverFromRect:rect inView:[self.delegate view] permittedArrowDirections:0 animated:YES];
        }
        else{
            [self.delegate presentModalViewController:self.imagePicker animated:YES];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Source for photo available" message:@"It seems the device do not have the Photogallery configured." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - UIAlertView-Delegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0: //Cancel
            [self imagePickerControllerDidCancel];
            break;
        case 1://Camera Roll
            [self takePhoto];
            break;
        case 2://Photo Video
            [self takeVideo];
            break;
        case 3://Photo Gallery
            [self openPhotoLibrary];
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSLog(@"Video is taken");
        [self captured_VIDEO_handler_WithInfo:info];
    }else{
        NSLog(@"image is taken");
        [self captured_IMAGE_handler_WithInfo:info];
    }
}

-(void)imagePickerControllerDidCancel{
    if ([self.cameraPopover isPopoverVisible]) {
        self.imagePicker = nil;
        [self.cameraPopover dismissPopoverAnimated:YES];
        self.failureCallback(@"imagePickerControllerDidCancel");
    }else{
        [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
        self.failureCallback(@"imagePickerControllerDidCancel");
    }
}

#pragma mark - Captured VIDEO Handler
-(void)captured_VIDEO_handler_WithInfo:(NSDictionary *)info{
    NSURL *fileURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    NSLog(@"Video Time in seconds is: %.2f",[self getVideoDuration_withURL:fileURL]);
    float videoDuration=[self getVideoDuration_withURL:fileURL];
    float maxVideoDuration=[[NSString stringWithFormat:@"%d",kMaxVideoCaptureDuration] floatValue];
    if (videoDuration>maxVideoDuration) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Max video size is 10 seconds.\nPlease choose again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    UIImage *capturedVideoThumb =[self thumbnailFromVideoAtURL:fileURL];
    
    if ([self.cameraPopover isPopoverVisible]) {
        self.imagePicker = nil;
        self.successCallback(YES,capturedVideoThumb,fileURL);
        [self.cameraPopover dismissPopoverAnimated:YES];
    }else{
        [self.imagePicker dismissViewControllerAnimated:YES completion:^{
            self.imagePicker = nil;
            self.successCallback(YES,capturedVideoThumb,fileURL);
        }];
    }
}

-(float)getVideoDuration_withURL:(NSURL *)url{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    CMTime duration = playerItem.duration;
    float seconds = CMTimeGetSeconds(duration);
    NSLog(@"duration: %.2f", seconds);
    return seconds;
}

#pragma mark - Captured IMAGE Handler
-(void)captured_IMAGE_handler_WithInfo:(NSDictionary *)info{
    UIImage *capturedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if ([self.cameraPopover isPopoverVisible]) {
        self.imagePicker = nil;
        self.successCallback(NO,capturedImage,nil);
        [self.cameraPopover dismissPopoverAnimated:YES];
    }else{
        [self.imagePicker dismissViewControllerAnimated:YES completion:^{
            self.imagePicker = nil;
            self.successCallback(NO,capturedImage,nil);
        }];
    }
}

#pragma mark - Helper Function
- (UIImage *)thumbnailFromVideoAtURL:(NSURL *)contentURL {
    UIImage *theImage = nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    theImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);
    return theImage;
}

@end