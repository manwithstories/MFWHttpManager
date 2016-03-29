//
//  DownloadViewController.m
//  HttpManager
//
//  Created by chuyanling on 15/11/12.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "DownloadViewController.h"
#import "MFWHttpDataTask.h"
#import "MFWHttpTaskEngine.h"

#define DOWN_FILE @"http://supportdownload.apple.com/download.info.apple.com/Apple_Support_Area/Apple_Software_Updates/Mac_OS_X/downloads/031-03190.20140529.Pp3r4/JavaForOSX2014-001.dmg"

//#define DOWN_FILE @"http://dlsw.baidu.com/sw-search-sp/soft/10/25851/jdk-8u40-macosx-x64.1427945120.dmg"
#define  DOWN_PATH @"/Documents/download/1"

@interface DownloadViewController()

@property(nonatomic,strong)UIProgressView *progressView1;
@property(nonatomic,strong)UIButton *button1;
@property (nonatomic,strong)MFWHttpDataTask *task1;

@property(nonatomic,strong)UIProgressView *progressView2;
@property(nonatomic,strong)UIButton *button2;
@property (nonatomic,strong)MFWHttpDataTask *task2;
@property (nonatomic,strong)MFWHttpTaskEngine *engine;


@end

@implementation DownloadViewController


- (void)viewDidLoad
{
    self.progressView1 = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 100, self.view.frame.size.width-150, 20)];
    [self.progressView1 setProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView1.progressTintColor=[UIColor blueColor];
    [self.view addSubview:self.progressView1];
    
    self.button1 = [[UIButton alloc] initWithFrame:CGRectMake(self.progressView1.frame.origin.x+self.progressView1.frame.size.width+10,self.progressView1.frame.origin.y-10, 40, 30)] ;
    [self.button1 addTarget:self action:@selector(clickButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.button1 setTitle:@"开始" forState:UIControlStateNormal];
    [self.button1 setTitle:@"暂停" forState:UIControlStateSelected];
    [self.button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button1 setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    self.button1.layer.borderColor = [UIColor grayColor].CGColor;
    self.button1.layer.borderWidth = 1.0f;
    [self.view addSubview:self.button1];
    
    
    self.progressView2 = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 160, self.view.frame.size.width-150, 20)];
    [self.progressView2 setProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView1.progressTintColor=[UIColor blueColor];
    [self.view addSubview:self.progressView2];
    
    self.button2 = [[UIButton alloc] initWithFrame:CGRectMake(self.progressView2.frame.origin.x+self.progressView2.frame.size.width+10,self.progressView2.frame.origin.y-10, 40, 30)] ;
    [self.button2 addTarget:self action:@selector(clickButton2:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 setTitle:@"开始" forState:UIControlStateNormal];
    [self.button2 setTitle:@"暂停" forState:UIControlStateSelected];
    [self.button2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    self.button2.layer.borderColor = [UIColor grayColor].CGColor;
    self.button2.layer.borderWidth = 1.0f;
    [self.view addSubview:self.button2];
    
    self.engine = [[MFWHttpTaskEngine alloc] init];

}

- (void)clickButton1:(UIButton*)btn{

    __weak DownloadViewController *wself = self;
    if(!btn.selected){
        self.task1 = [[MFWHttpDataTask alloc] init];
        self.task1.request.requestTimeout = 10;
        self.task1.request.httpMethod = MFWRequestHttpMethodGet;
        self.task1.request.URLString = DOWN_FILE;
        self.task1.taskType = MFWHttpTaskTypeDownload;
        
         NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),DOWN_PATH];
        self.task1.saveDownloadFilePath = path ;
        self.task1.progerssBlock = ^(MFWHttpDataTask *task,NSProgress *progress){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself.progressView1 setProgress:progress.fractionCompleted];
            });
        };
        
        [self.engine executeTask:self.task1 completion:^(MFWHttpDataTask *task, BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
            
        }];
        
        
    }else{
        [self.engine cancelTask:self.task1];
    }
    btn.selected = !btn.selected;
}


- (void)clickButton2:(UIButton*)btn{
   
    if(!btn.selected){
        self.task2 = [[MFWHttpDataTask alloc] init];
        self.task2.request.requestTimeout = 10;
        self.task2.request.httpMethod = MFWRequestHttpMethodGet;
        self.task2.request.URLString = DOWN_FILE;
        self.task2.taskType = MFWHttpTaskTypeDownload;
         NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),DOWN_PATH];
        self.task2.saveDownloadFilePath = path ;
        __weak DownloadViewController *wself = self;
        self.task2.progerssBlock = ^(MFWHttpDataTask *task,NSProgress *progress){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself.progressView2 setProgress:progress.fractionCompleted animated:YES];
            });
        };
        [self.engine executeTask:self.task2 completion:^(MFWHttpDataTask *aTask, BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
            if(error == nil){
                 NSLog(@"下载完成了");
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [wself.progressView2 setProgress:1];
                });
            }else{
                NSLog(@"%@",error);
            }
        }];
    }else{
        [self.engine cancelTask:self.task2];
    }
    btn.selected = !btn.selected;
}


@end
