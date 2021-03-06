//
//  CameraPickerViewManager.h
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

#import <Foundation/Foundation.h>
typedef void(^CameraPickerViewSuccessBlock)(BOOL isVideo,UIImage *image, NSURL* videoURL);
typedef void(^CameraPickerViewCancelBlock)(id info);

@interface CameraPickerViewManager : NSObject
<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate>
@property(nonatomic, copy)CameraPickerViewSuccessBlock successCallback;
@property(nonatomic, copy)CameraPickerViewCancelBlock  failureCallback;
@property(nonatomic, weak)id delegate;
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)UIPopoverController *cameraPopover;

-(void)showImagePickerWithDelegate:(id)VCdelegate onSuccess:(CameraPickerViewSuccessBlock)success onFailureOrCancel:(CameraPickerViewCancelBlock)cancelBlock;
@end

