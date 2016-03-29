//
//  UploadViewController.m
//  HttpManager
//
//  Created by chuyanling on 15/11/12.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "UploadViewController.h"
#import "MFWHttpTaskEngine.h"

@interface UploadViewController()

@property (nonatomic,strong)MFWHttpTaskEngine *engine;

@end

@implementation UploadViewController


-(void)viewDidLoad
{
    [super viewDidLoad];

    self.engine = [[MFWHttpTaskEngine alloc] init];
    MFWHttpDataTask *task = [MFWHttpDataTask taskWithURLString:@"http://172.18.20.193/upload.php" method:MFWRequestHttpMethodPost params:nil taskType:MFWHttpTaskTypeUpload];
   
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    task.uploadData = @{@"aaa": url,@"bbb":url,@"ccc":url};
    
    [self.engine executeTask:task completion:^(MFWHttpDataTask*aTask, BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    task.progerssBlock = ^(MFWHttpDataTask *task,NSProgress *progress){
        NSLog(@"上传了---->%f",progress.fractionCompleted);
    };
}

@end
