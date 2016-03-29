//  MFWHttpTaskEngine.m
//  Created by MFWMobile on 15/8/20.
//  Copyright © 2015年 MFWMobile. All rights reserved.

#import "MFWHttpTaskEngine.h"
#import "MFWHttpTaskAFNEngine.h"
#import "MFWResponseHandlerPipeline.h"
#import "MFWRequestBuilderPipeline.h"
#import "MFWHttpManager.h"

@interface MFWHttpTaskEngine ()
@end


@implementation MFWHttpTaskEngine  //类簇

+ (instancetype)alloc
{
    if ([self class] == [MFWHttpTaskEngine class]) {
        return [MFWHttpTaskAFNEngine alloc];
    } else {
        return [super alloc];
    }
}

#pragma mark -

- (void)executeTask:(MFWHttpDataTask *)httpTask completion:(MFWHttpTaskCompletion)completion
{
    MFWHttpManagerAssert(NO, @"父类不应该实现该方法");
}

- (void)cancelTask:(MFWHttpDataTask *)httpTask
{
    MFWHttpManagerAssert(NO, @"父类不应该实现该方法");
}

- (void)cancelAllTask
{
    MFWHttpManagerAssert(NO, @"父类不应该实现该方法");
}

@end
