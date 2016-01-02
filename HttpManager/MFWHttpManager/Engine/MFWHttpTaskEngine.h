//  MFWHttpTaskEngine.h
//  Created by MFWMobile on 15/8/20.
//  Copyright © 2015年 MFWMobile. All rights reserved.

#import <Foundation/Foundation.h>
#import "MFWHttpTask.h"

@interface MFWHttpTaskEngine : NSObject


//默认类型的引擎
+ (MFWHttpTaskEngine *)defaultEngine;


//根据标示符产生一个单例的Engine
- (instancetype)initWithSingleIdentifier:(NSString *)identifier;


//普通请求
- (void)executeTask:(MFWHttpTask *)httpTask
        complection:(MFWHttpTaskCompletion)completion;

- (void)cancelTask:(MFWHttpTask *)httpTask;
- (void)cancelAllTask;

@property (nonatomic, strong,readonly) NSMutableArray<MFWHttpTask *> *httpTasks;
//plugin
@property (nonatomic, copy) id <HttpRequestBuildProtocol> requestPlugin;      //请求处理插件
@property (nonatomic, copy) id <HttpResponseHandleProtocol> responsePlugin;   //响应解析插件

@end
