//
//  TestPrivateResponsePlugin.m
//  HttpManager
//
//  Created by 刘澈 on 15/11/20.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "TestPrivateResponsePlugin.h"

@implementation TestPrivateResponsePlugin

@synthesize responseHandleBlock = _responseHandleBlock;

-(instancetype)init
{
    self = [super init];
    if(self){
        _responseHandleBlock = ^(MFWHttpDataTask *httpTask){
            NSLog(@"私有后插件执行了~~~~~");
        };
        self.runningInBackground = YES;
    }
    return self;
}


@end
