//
//  ViewController.m
//  HttpManager
//
//  Created by 刘澈 on 15/8/28.
//  Copyright (c) 2015年 刘澈. All rights reserved.
//

#import "NormalViewController.h"
#import "MFWHttpTaskEngine.h"
#import "MFWHttpTask.h"
#import "HttpRequestBuildProtocol.h"
#import "MFWRequestBaseBuilder.h"
#import "MFWRequestBuilderPipeline.h"
#import "MFWResponseHandlerPipeline.h"
#import "TestPrivateRequstPugin.h"
#import "TestPrivateResponsePlugin.h"


@interface NormalViewController ()<HttpRequestBuildProtocol>

@property(nonatomic,strong)UITextView *textView;

@property (nonatomic,strong)UIActivityIndicatorView * activityIndicatorView;

@end

@implementation NormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(40, 80, self.view.frame.size.width-80, 30)];
    [button setTitle:@"发起请求" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor orangeColor].CGColor;
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 4.0f;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(25, 120, self.view.frame.size.width-50, self.view.frame.size.height-120-150-10)];
    self.textView.font = [UIFont systemFontOfSize:13];
    self.textView.textColor = [UIColor blackColor];
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor blueColor].CGColor;
    self.textView.clipsToBounds = YES;
    self.textView.layer.cornerRadius = 4.0f;
    [self.view addSubview:self.textView];
}



- (void)foo:(UIButton *)btn
{
    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine defaultEngine];
    btn.userInteractionEnabled = NO;
    self.textView.text = @"";
    [self showIndicatorView];
    
    for(int i=0;i<100;i++){
        MFWHttpTask *task =  [[MFWHttpTask alloc] init];
        
        task.request.reqeustTimeout = 10;
        task.request.httpMethod = HttpMethodGet;
        task.request.URLString = @"http://182.92.72.114/source/plugin/aimdev/api/simulate/simulatelist.php";
        
        TestPrivateRequstPugin *privateRequestPlugin = [TestPrivateRequstPugin builder];
        
        task.requestPlugin = [MFWRequestBuilderPipeline builderPipeline:@[privateRequestPlugin]];
        
        task.responsePlugin = [MFWResponseHandlerPipeline builderPipeline:@[[TestPrivateResponsePlugin handler]]];
        
        
        __weak NormalViewController *wself = self;
        [engine executeTask:task complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
            NormalViewController *sself = wself;
            if(succeed){
//               NSError *changeError = nil;
//              NSData *dataStr = [NSJSONSerialization dataWithJSONObject:responeseData options:NSJSONWritingPrettyPrinted error:&changeError];
//              if(changeError == nil){
//                  NSString *str = [[NSString alloc] initWithData:dataStr encoding:NSUTF8StringEncoding];
//                  sself.textView.text = str;
//              }else{
//                   sself.textView.text = [changeError description];
//              }
            }else{
                sself.textView.text = [error description];
            }
            
            btn.userInteractionEnabled = YES;
            [sself hideIndicatorView];
        }];
    }
    
    NSLog(@"%@",[engine httpTasks]);
}

-(void)buttonClick:(UIButton *)btn
{
    [self performSelector:@selector(foo:) withObject:btn afterDelay:0.01f];
    
    [self performSelector:@selector(foo:) withObject:btn afterDelay:1.0f];
    
    [self performSelector:@selector(foo:) withObject:btn afterDelay:2.0f];
    
    [self performSelector:@selector(foo:) withObject:btn afterDelay:1.5f];
}

- (void)showIndicatorView
{
    if(self.activityIndicatorView == nil){
        self.activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.activityIndicatorView.center=self.view.center;
        [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityIndicatorView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:self.activityIndicatorView];
    }
    [self.activityIndicatorView startAnimating];
}

- (void)hideIndicatorView
{
    [self.activityIndicatorView stopAnimating];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
