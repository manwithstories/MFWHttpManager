//  MFWHttpTaskEngine.h
//  Created by MFWMobile on 15/8/20.
//  Copyright © 2015年 MFWMobile. All rights reserved.

#import <Foundation/Foundation.h>
#import "MFWHttpDataTask.h"

@interface MFWHttpTaskEngine : NSObject

//普通请求
- (void)executeTask:(MFWHttpDataTask *)httpTask
        complection:(MFWHttpTaskCompletion)completion;

- (void)cancelTask:(MFWHttpDataTask *)httpTask;
- (void)cancelAllTask;


//plugin
@property (nonatomic, copy) id <HttpRequestBuildProtocol> requestPlugin;      //请求处理插件
@property (nonatomic, copy) id <HttpResponseHandleProtocol> responsePlugin;   //响应解析插件
@property (nonatomic,strong,readonly) NSArray *httpTasks;//所有加入engine的 MFWHttpTask。
@property (nonatomic,assign) NSUInteger HTTPMaximumConnectionsPerHost;
@property (nonatomic,assign) NSUInteger maxConcurrentOperationCount;

@end



