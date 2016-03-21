//
//  TestPrivateRequstPugine.m
//  HttpManager
//
//  Created by 刘澈 on 15/11/20.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "TestPrivateRequstPugin.h"

@implementation TestPrivateRequstPugin

@synthesize requestBuildBlock = _requestBuildBlock;

- (instancetype)init
{
    self = [super init];
    if(self){
        _requestBuildBlock = ^(MFWHttpDataTask *httpTask){
            NSLog(@"私有前插件执行~~~~~~~~~~~");
        };
    }
    return self;
}


@end
