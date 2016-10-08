//
//  ViewController.h
//  MyHybridDemo
//
//  Created by luoyan on 16/9/23.
//  Copyright © 2016年 ly. All rights reserved.
//

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>

#define WWWContentFrom WWWFromAPPDocumentDir

typedef NS_ENUM(NSInteger, WWWContentSource) {
    WWWFromRemoteServer = 1,
    WWWFromAPPContentDir,
    WWWFromAPPDocumentDir
};

@interface MainHybridFrameController : CDVViewController

@end


@interface MainCommandDelegate : CDVCommandDelegateImpl
@end

@interface MainCommandQueue : CDVCommandQueue
@end
