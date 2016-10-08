//
//  ImagePicker.m
//  SellHouseManager
//
//  Created by yangxu on 16/9/8.
//  Copyright © 2016年 JiCe. All rights reserved.
//

#import "PhotoPickerPlugin.h"
#import "TZImageManager.h"
#import "MicAssistant.h"
#import "HUDManager.h"

@interface PhotoPickerPlugin()<TZImagePickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) CDVInvokedUrlCommand *pCommand;
@end

@implementation PhotoPickerPlugin


- (void)getPictures:(CDVInvokedUrlCommand *)command
{
    self.pCommand = command;
    UIActionSheet *actionView = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"相机拍摄", nil];
    [actionView showInView:self.viewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 相册
        [self getPicturesFromSys];
    } else if (buttonIndex == 1) {
        // 相机
        [self takePhoto];
    }
}

#pragma mark 重相册中选择图片
- (void)getPicturesFromSys
{
    // 最多可选择的数目
    NSInteger maxCount = [[self.pCommand.arguments objectAtIndex:0] integerValue];
    maxCount = maxCount<0?0:maxCount;
    
    [self.commandDelegate runInBackground:^{
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount delegate:self];
        imagePickerVc.isSelectOriginalPhoto = NO;
        imagePickerVc.allowTakePicture = NO;
        imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
        imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
        imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingOriginalPhoto = NO;
        imagePickerVc.maxImagesCount = maxCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
        });
    }];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    CDVPluginResult* result = nil;
    NSMutableArray *resultStrings = [[NSMutableArray alloc] init];
    NSData* data = nil;
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSString* filePath;
    
    for (UIImage *image in photos) {
        int i = 1;
        do {
            filePath = [NSString stringWithFormat:@"%@/%@%04d.%@", [self getFileDocPath], @"cdv_photo_", i++, @"jpg"];
        } while ([fileMgr fileExistsAtPath:filePath]);
        
        @autoreleasepool {
            data = UIImageJPEGRepresentation(image,0.5);
            if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                break;
            } else {
                [resultStrings addObject:[[NSURL fileURLWithPath:filePath] absoluteString]];
            }
        }
    }
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultStrings];
    [self.commandDelegate sendPluginResult:result callbackId:self.pCommand.callbackId];
}

#pragma mark 拍照
- (void)takePhoto
{    
    if (![[MicAssistant sharedInstance] checkAccessPermissions:NoAccessCamaratype]) {
        return;
    }
    
    [self.commandDelegate runInBackground:^{
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerVc.sourceType = sourceType;
            if(iOS8Later) {
                _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self.viewController presentViewController:_imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if ([[MicAssistant sharedInstance] isCurrentAppALAssetsLibraryServiceOn]) {
            [HUDManager showHUDWithMessage:@"请稍候..."];
            [[TZImageManager manager] savePhotoWithImage:image completion:(void (^)(NSError *error))^{
                [HUDManager hiddenHUD];
                NSFileManager* fileMgr = [[NSFileManager alloc] init];
                NSError* err = nil;
                CDVPluginResult *result = nil;
                NSString* filePath = nil;
                
                int i = 1;
                do {
                    filePath = [NSString stringWithFormat:@"%@/%@%04d.%@", [self getFileDocPath], @"cdv_photo_", i++, @"jpg"];
                } while ([fileMgr fileExistsAtPath:filePath]);
                
                @autoreleasepool {
                    NSData* data = UIImageJPEGRepresentation(image,0.2);
                    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                    } else {
                        filePath = [[NSURL fileURLWithPath:filePath] absoluteString];
                    }
                }
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[filePath]];
                [self.commandDelegate sendPluginResult:result callbackId:self.pCommand.callbackId];
            }];
        } else {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"保存图片失败"];
            [self.commandDelegate sendPluginResult:result callbackId:self.pCommand.callbackId];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        _imagePickerVc.navigationBar.barTintColor = self.viewController.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.viewController.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

// 删除图片文件
- (void)deleteFile:(CDVInvokedUrlCommand *)command
{
    self.pCommand = command;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSArray *filePaths = self.pCommand.arguments;
    for (int i = 0; i<filePaths.count; i++) {
        NSString *filePath = [filePaths objectAtIndex:i];
        NSString *fileName = [fileMgr displayNameAtPath:filePath];
        NSLog(@"fileName = %@",fileName);
        NSString *file = [NSString stringWithFormat:@"%@/%@",[self getFileDocPath],fileName];
        if ([fileMgr fileExistsAtPath:file]) {
            [fileMgr removeItemAtPath:file error:nil];
        }
    }
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:result callbackId:self.pCommand.callbackId];
}

- (NSString *)getFileDocPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *financeFile = [NSString stringWithFormat:@"%@/financeFile",documentsDirectory];
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    BOOL isDir = YES;
    if (![fileMgr fileExistsAtPath:financeFile isDirectory:&isDir]) {
        [fileMgr createDirectoryAtPath:financeFile withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return financeFile;
}

@end
