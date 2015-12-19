//
//  UploadViewController.m
//  HttpManager
//
//  Created by chuyanling on 15/11/12.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "UploadViewController.h"
#import "MFWHttpTaskEngine.h"

@implementation UploadViewController


-(void)viewDidLoad
{
    [super viewDidLoad];

    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine defaultEngine];
    MFWHttpTask *task = [MFWHttpTask taskWithURLString:@"http://example.com/upload" method:HttpMethodPost params:nil taskType:HttpTaskTypeUpload];
   
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    task.uploadData = @{@"aaa": url,@"bbb":url,@"ccc":url};
    
    [engine executeTask:task complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    task.progerssBlock = ^(MFWHttpTask *task,NSProgress *progress){
        NSLog(@"上传了---->%f",progress.fractionCompleted);
    };
}

@end
