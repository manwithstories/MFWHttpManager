//
//  TestPublicRequstPugin.m
//  HttpManager
//
//  Created by 刘澈 on 15/11/20.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "TestPublicRequstPugin.h"

@implementation TestPublicRequstPugin

@synthesize requestBuildBlock = _requestBuildBlock;

- (instancetype)init
{
    self = [super init];
    if(self){
        _requestBuildBlock = ^(MFWHttpTask *httpTask){
            NSLog(@"公有前插件执行~~~~~~~~~~~");
        };
    }
    return self;
}


@end
