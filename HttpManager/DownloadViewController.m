//
//  DownloadViewController.m
//  HttpManager
//
//  Created by chuyanling on 15/11/12.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "DownloadViewController.h"
#import "MFWhttpTask.h"
#import "MFWHttpTaskEngine.h"

#define DOWN_FILE @"http://supportdownload.apple.com/download.info.apple.com/Apple_Support_Area/Apple_Software_Updates/Mac_OS_X/downloads/031-03190.20140529.Pp3r4/JavaForOSX2014-001.dmg"

@interface DownloadViewController()

@property(nonatomic,strong)UIProgressView *progressView1;
@property(nonatomic,strong)UIButton *button1;
@property (nonatomic,strong)MFWHttpTask *task1;

@property(nonatomic,strong)UIProgressView *progressView2;
@property(nonatomic,strong)UIButton *button2;
@property (nonatomic,strong)MFWHttpTask *task2;


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

}

- (void)clickButton1:(UIButton*)btn{
    MFWHttpTaskEngine *engine =  [MFWHttpTaskEngine defaultEngine];
    if(!btn.selected){
        self.task1 = [[MFWHttpTask alloc] init];
        self.task1.request.reqeustTimeout = 10;
        self.task1.request.httpMethod = HttpMethodGet;
        self.task1.request.URLString = DOWN_FILE;
        self.task1.taskType = HttpTaskTypeDownload;
        
        self.task1.progerssBlock = ^(MFWHttpTask *task,NSProgress *progress){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.progressView1 setProgress:progress.fractionCompleted];
            });
        };
        
        [engine executeTask:self.task1 complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
            
        }];
    }else{
        [engine cancelTask:self.task1];
    }
    btn.selected = !btn.selected;
}


- (void)clickButton2:(UIButton*)btn{
    MFWHttpTaskEngine *engine =  [MFWHttpTaskEngine defaultEngine];

    if(!btn.selected){
        self.task2 = [[MFWHttpTask alloc] init];
        self.task2.request.reqeustTimeout = 10;
        self.task2.request.httpMethod = HttpMethodGet;
        self.task2.request.URLString = DOWN_FILE;
        self.task2.taskType = HttpTaskTypeDownload;
        
        __weak DownloadViewController *wself = self;
        self.task2.progerssBlock = ^(MFWHttpTask *task,NSProgress *progress){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [wself.progressView2 setProgress:progress.fractionCompleted];
            });
        };
        [engine executeTask:self.task2 complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
            if(error == nil){
                 NSLog(@"下载完成了");
            }else{
                NSLog(@"%@",error);
            }
        }];
    }else{
        [engine cancelTask:self.task2];
    }
    btn.selected = !btn.selected;
}


@end
