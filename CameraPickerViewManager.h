//
//  CameraPickerViewManager.h
//  
//
//  Created by Manish Rathi on 13/06/13.
//

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

