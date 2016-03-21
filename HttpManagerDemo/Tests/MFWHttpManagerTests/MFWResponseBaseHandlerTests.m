//
//  MFWResponseBaseHandlerTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/28.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"
#import "MFWHttpDataTask.h"
#import "MFWHttpTaskEngine.h"
#import "MFWResponseBaseHandler.h"


@interface MFWResponseBaseHandlerTests : MFWHttpManagerTests

@property (nonatomic, strong) MFWResponseBaseHandler *handler;
@property (nonatomic, strong) MFWResponseBaseHandler *engineHandler;

@end



@implementation MFWResponseBaseHandlerTests

- (void)setUpClass
{
    [super setUpClass];
    self.handler = [MFWResponseBaseHandler handler];
    self.engineHandler = [MFWResponseBaseHandler handler];
}



/*
 目的：测试task后置插件是否执行
 */
- (void)testTaskPluginIsExecuted
{
//    __block BOOL isPluginExecuted = NO;
//    __block BOOL isComplection = NO;
//    __block BOOL pluginExecutedBefore = NO;
//    
//    self.handler.responseHandleBlock = ^(MFWHttpDataTask *task){
//        isPluginExecuted = YES;
//    };
//    
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    
//    task.responsePlugin = self.handler;
//    
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testPluginIsExecuted.responsePLugin"];
//    
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//                if (isPluginExecuted)
//                {
//                    pluginExecutedBefore = YES;
//                }
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isPluginExecuted, @"task plugin should be executed");
//    GHAssertTrue(isComplection, @"task should be complection with block executed");
//    GHAssertTrue(pluginExecutedBefore, @"task plugin should be executed before complection block");
}



/*
 目的：测试后置插件block 为空时代码的健壮性
 */
- (void)testTaskPluginWithBuildBlockIsNil
{
//    self.handler.responseHandleBlock = nil;
//    
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    task.responsePlugin = self.handler;
//    
//    __block BOOL isComplection = NO;
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine defaultEngine];
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"task should be complection even if plugin block is nil");
}



/*
 目的：测试Engine后置插件是否执行
 方式.1 : 当task plugin 与 engine plugin 同时存在时，测试执行顺序是否是 先engine 后 task
 */
- (void)testEnginPluginIsExecuted
{
//    __block BOOL isPluginExecuted = NO;
//    __block BOOL isEnginePluginExecuted = NO;
//    __block BOOL enginePluginExecutedBeforeTask = NO;
//    
//    __block BOOL isComplection = NO;
//    __block BOOL pluginExecutedBeforeComplection = NO;
//    
//    
//    self.engineHandler.responseHandleBlock = ^(MFWHttpDataTask *task)
//    {
//        isEnginePluginExecuted = YES;
//    };
//    
//    self.handler.responseHandleBlock = ^(MFWHttpDataTask *task){
//        isPluginExecuted = YES;
//        if (isEnginePluginExecuted)
//        {
//            enginePluginExecutedBeforeTask = YES;
//        }
//    };
//    
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    
//    task.responsePlugin = self.handler;
//    //
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testEnginResponsePluginIsExecuted"];
//    engine.responsePlugin = self.engineHandler;
//    
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//                if (isPluginExecuted && isEnginePluginExecuted)
//                {
//                    pluginExecutedBeforeComplection = YES;
//                }
//            }];
//    
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"task should be complection");
//    
//    GHAssertTrue(isPluginExecuted, @"response plugin of task should be executed");
//    GHAssertTrue(isEnginePluginExecuted, @"response plugin of engine should be executed");
//    
//    GHAssertTrue(enginePluginExecutedBeforeTask, @"response plugin of engine should executed before response plugin of task");
//    GHAssertTrue(pluginExecutedBeforeComplection, @"response plugins should be executed before complection block");
}


/*
 目的：测试后置插件block 为空时代码的健壮性
 方式.1 : task 的后置插件为 nil
 方式.2 : engine 的后置插件为 nil
 方式.3 : task 和 engine 的后置插件都为 nil
 */
- (void)testEnginePluginWithBuildBlockIsNil
{
//    __block BOOL isPluginExecuted = NO;
//    __block BOOL isEnginePluginExecuted = NO;
//    
//    __block BOOL isComplection = NO;
//    __block BOOL pluginExecutedBeforeComplection = NO;
//    
//    self.handler.responseHandleBlock = nil;
//    
//    self.engineHandler.responseHandleBlock = ^(MFWHttpDataTask *task)
//    {
//        isEnginePluginExecuted = YES;
//    };
//    
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    task.responsePlugin = self.handler;
//    
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testEngineResponsePluginWithBuildBlockIsNil"];
//    engine.responsePlugin = self.engineHandler;
//    
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//                if (isEnginePluginExecuted)
//                {
//                    pluginExecutedBeforeComplection = YES;
//                }
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"task should be complection even if task plugin block is nil");
//    GHAssertTrue(isEnginePluginExecuted, @"response plugin of engine should be executed");
//    
//    GHAssertTrue(pluginExecutedBeforeComplection, @"response plugin should be executed before complection block with task plugin nil");
//    
//    //方式.2
//    isComplection = NO;
//    isEnginePluginExecuted = NO;
//    pluginExecutedBeforeComplection = NO;
//    
//    self.handler.responseHandleBlock = ^(MFWHttpDataTask *task){
//        isPluginExecuted = YES;
//    };
//    self.engineHandler.responseHandleBlock = nil;
//    
//    task.responsePlugin = self.handler;
//    task.allowRepeat = YES;
//    engine.responsePlugin = self.engineHandler;
//    
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//                if (isPluginExecuted)
//                {
//                    pluginExecutedBeforeComplection = YES;
//                }
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"task should be complection even if engine plugin block is nil");
//    GHAssertTrue(isPluginExecuted, @"response plugin of task should be executed");
//    GHAssertTrue(pluginExecutedBeforeComplection, @"response plugin should be executed before complection block with engine plugin nil");
//    
//    //方式.3
//    isComplection = NO;
//    isPluginExecuted = NO;
//    pluginExecutedBeforeComplection = NO;
//    
//    self.handler.responseHandleBlock = nil;
//    self.engineHandler.responseHandleBlock = nil;
//    
//    task.responsePlugin = self.handler;
//    task.allowRepeat = YES;
//    engine.responsePlugin = self.engineHandler;
//    
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"task should be complection even if task and engine response plugin blocks are nil");
}



/*
 目的: 测试 NSCopy 协议
 */
- (void)testCanBeCopied
{
    MFWResponseBaseHandler *handlerCopied = [self.handler copy];
    
    GHAssertNotNil(handlerCopied, @"copy handler should not be nil");
    GHAssertNotEqualObjects(handlerCopied, self.handler, @"copy-objects should not be equal to objects");
}


@end
