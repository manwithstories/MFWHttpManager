//
//  TestPublicResponsePlugin.m
//  HttpManager
//
//  Created by 刘澈 on 15/11/20.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "TestPublicResponsePlugin.h"

@implementation TestPublicResponsePlugin

@synthesize responseHandleBlock = _responseHandleBlock;

-(instancetype)init
{
    self = [super init];
    if(self){
        _responseHandleBlock = ^(MFWHttpDataTask *httpTask){
            NSLog(@"公有后插件执行了~~~~~");
        };
    }
    return self;
}

@end
