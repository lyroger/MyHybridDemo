//
//  ViewController.m
//  MyHybridDemo
//
//  Created by luoyan on 16/9/23.
//  Copyright © 2016年 ly. All rights reserved.
//

#import "MainHybridFrameController.h"

@interface MainHybridFrameController ()

@end

@implementation MainHybridFrameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    
    NSString *path = nil;
    switch (WWWContentFrom) {
        case WWWFromAPPContentDir:
        {
            NSBundle* mainBundle = [NSBundle mainBundle];
            NSMutableArray* directoryParts = [NSMutableArray arrayWithArray:[resourcepath componentsSeparatedByString:@"/"]];
            NSString* filename = [directoryParts lastObject];
            
            [directoryParts removeLastObject];
            
            NSString* directoryPartsJoined = [directoryParts componentsJoinedByString:@"/"];
            NSString* directoryStr = @"www";
            
            if ([directoryPartsJoined length] > 0) {
                directoryStr = [NSString stringWithFormat:@"%@/%@", directoryStr, [directoryParts componentsJoinedByString:@"/"]];
            }
            
            path = [mainBundle pathForResource:filename ofType:@"" inDirectory:directoryStr];
        }
            break;
            
        case WWWFromAPPDocumentDir:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *www = [documentsDirectory stringByAppendingPathComponent:@"www"];
            path = [www stringByAppendingPathComponent:resourcepath];
            
        }
            break;
            
        case WWWFromRemoteServer:
        {
            
        }
            break;
        default:
            break;
    }
    
    return path;
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
