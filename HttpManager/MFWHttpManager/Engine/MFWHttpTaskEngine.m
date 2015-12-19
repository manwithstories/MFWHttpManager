//  MFWHttpTaskEngine.m
//  Created by MFWMobile on 15/8/20.
//  Copyright © 2015年 MFWMobile. All rights reserved.

#import "MFWHttpTaskEngine.h"
#import "MFWHttpTaskAFNEngine.h"
#import "MFWResponseHandlerPipeline.h"
#import "MFWRequestBuilderPipeline.h"


static NSMutableDictionary<NSString*,MFWHttpTaskEngine*> *s_globalConfig;

@interface MFWHttpTaskEngine ()
@end

@implementation MFWHttpTaskEngine

+ (instancetype)alloc
{
    if(s_globalConfig == nil){
        s_globalConfig = [NSMutableDictionary dictionary];
    }
    return [super alloc];
}

- (instancetype)init
{
    self = [super init];
    if(self){
        _httpTasks = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithSingleIdentifier:(NSString *)identifier
{
    @synchronized(s_globalConfig) {
        if([s_globalConfig objectForKey:identifier] != nil){
            return [s_globalConfig objectForKey:identifier];
        }else{
            self = [self init];
            if(self){
                [s_globalConfig setObject:self forKey:identifier];
            }
            return self;
        }
    }
}

+ (MFWHttpTaskEngine *)defaultEngine
{
    return [MFWHttpTaskAFNEngine defaultEngine];
}


#pragma mark -
- (void)executeTask:(MFWHttpTask *)httpTask complection:(MFWHttpTaskCompletion)completion
{
    NSAssert(NO, @"父类不应该实现该方法");
}

- (void)cancelTask:(MFWHttpTask *)httpTask
{
    NSAssert(NO, @"父类不应该实现该方法");
}

- (void)cancelAllTask
{
    NSAssert(NO, @"父类不应该实现该方法");
}

@end
