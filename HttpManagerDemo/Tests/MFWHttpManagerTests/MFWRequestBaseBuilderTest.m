//
//  MFWRequestBaseBuilderTest.m
//  HttpManager
//
//  Created by chuyanling on 15/12/25.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"
#import "MFWRequestBaseBuilder.h"

#import "MFWHttpDataTask.h"
#import "MFWHttpTaskEngine.h"

/*
 MFWRequestBaseBuilder --- 请求前置插件
 MFWRequestBaseBuilderTests -- 测试请求前置插件的执行情况以及参数准确性以及NSCopying 协议的支持
*/



@interface MFWRequestBaseBuilderTests : MFWHttpManagerTests

@property (nonatomic, strong) MFWRequestBaseBuilder *builder;
@property (nonatomic, strong) MFWRequestBaseBuilder *enginBuilder;

@property (nonatomic, copy) MFWhttpRequestBuildBlock builderBlock;

@end


@implementation MFWRequestBaseBuilderTests


- (void)setUpClass
{
    [super setUpClass];
    
    self.builder = [MFWRequestBaseBuilder builder];
    self.enginBuilder = [MFWRequestBaseBuilder builder];

}



/*
  目的：测试task前置插件是否执行
 */
- (void)testTaskPluginIsExecuted
{
//    __block BOOL isPluginExecuted = NO;
//    __block BOOL isComplection = NO;
//    __block BOOL pluginExecutedBefore = NO;
//
//    self.builder.requestBuildBlock = ^(MFWHttpDataTask *task){
//        isPluginExecuted = YES;
//    };
//    
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    
//    task.requestPlugin = self.builder;
//    
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testPluginIsExecuted"];
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
//    GHAssertTrue(isComplection, @"task should be complection with block executed");
//    GHAssertTrue(isPluginExecuted, @"task plugin should be executed");
//    GHAssertTrue(pluginExecutedBefore, @"task plugin should be executed before complection block");
}



/*
 目的：测试task 的前置插件block 为空时代码的健壮性
 方式.1 : task 的前置插件为 nil
 */

- (void)testTaskPluginWithBuildBlockIsNil
{
//    self.builder.requestBuildBlock = nil;
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    task.requestPlugin = self.builder;
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
 目的：测试Engine前置插件是否执行
 方式.1 : 当task plugin 与 engine plugin 同时存在时，测试执行顺序是否是 先task 后 engine
 */
- (void)testEnginPluginIsExecuted
{
//    __block BOOL isPluginExecuted = NO;
//    __block BOOL isEnginePluginExecuted = NO;
//    __block BOOL taskPluginExecutedBeforeEngine = NO;
//
//    __block BOOL isComplection = NO;
//    __block BOOL pluginExecutedBeforeComplection = NO;
//    
//    self.builder.requestBuildBlock = ^(MFWHttpDataTask *task){
//        isPluginExecuted = YES;
//    };
//    
//    self.enginBuilder.requestBuildBlock = ^(MFWHttpDataTask *task)
//    {
//        isEnginePluginExecuted = YES;
//        if (isPluginExecuted)
//        {
//            taskPluginExecutedBeforeEngine = YES;
//        }
//    };
//    
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    
//    task.requestPlugin = self.builder;
//    
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testEnginPluginIsExecuted"];
//    engine.requestPlugin = self.enginBuilder;
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
//    GHAssertTrue(isPluginExecuted, @"plugin of task should be executed");
//    GHAssertTrue(isEnginePluginExecuted, @"plugin of engine should be executed");
//    
//    GHAssertTrue(taskPluginExecutedBeforeEngine, @"plugin of task should executed before plugin of engine");
//    GHAssertTrue(pluginExecutedBeforeComplection, @"plugin should be executed before complection block");
    
}

/*
 目的：测试前置插件block 为空时代码的健壮性
 方式.1 : task 的前置插件为 nil
 方式.2 : engine 的前置插件为 nil
 方式.3 : task 和 engine 的插件都为 nil
 */
- (void)testEnginePluginWithBuildBlockIsNil
{
    __block BOOL isPluginExecuted = NO;
//    __block BOOL isEnginePluginExecuted = NO;
//    
//    __block BOOL isComplection = NO;
//    __block BOOL pluginExecutedBeforeComplection = NO;
//
//    self.builder.requestBuildBlock = nil;
//    self.enginBuilder.requestBuildBlock = ^(MFWHttpDataTask *task)
//    {
//        isEnginePluginExecuted = YES;
//    };
//
//    MFWHttpDataTask *task =
//    [MFWHttpDataTask taskWithURLString:self.test_request_url
//                            method:0
//                            params:nil
//                          taskType:0];
//    task.requestPlugin = self.builder;
//    
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testEnginePluginWithBuildBlockIsNil.1"];
//    engine.requestPlugin = self.enginBuilder;
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
//    GHAssertTrue(isEnginePluginExecuted, @"plugin of engine should be executed");
//    
//    GHAssertTrue(pluginExecutedBeforeComplection, @"plugin should be executed before complection block with task plugin nil");
//
//    //方式.2
//    isComplection = NO;
//    isEnginePluginExecuted = NO;
//    pluginExecutedBeforeComplection = NO;
//    
//    self.builder.requestBuildBlock = ^(MFWHttpDataTask *task){
//        isPluginExecuted = YES;
//    };
//    self.enginBuilder.requestBuildBlock = nil;
//    task.requestPlugin = self.builder;
//    task.allowRepeat = YES;
//    engine.requestPlugin = self.enginBuilder;
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
//    GHAssertTrue(isPluginExecuted, @"plugin of task should be executed");
//    GHAssertTrue(pluginExecutedBeforeComplection, @"plugin should be executed before complection block with engine plugin nil");
//
//    //方式.3
//    isComplection = NO;
//    isPluginExecuted = NO;
//    pluginExecutedBeforeComplection = NO;
//    
//    self.builder.requestBuildBlock = nil;
//    self.enginBuilder.requestBuildBlock = nil;
//    task.requestPlugin = self.builder;
//    task.allowRepeat = YES;
//    engine.requestPlugin = self.enginBuilder;
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"task should be complection even if task and engine plugin blocks are nil");
}




/*
  目的: 测试 NSCopy 协议
 */
- (void)testCanBeCopied
{
    MFWRequestBaseBuilder *builer = [self.builder copy];
    
    GHAssertNotNil(builer, @"copy self.builder should not be nil");
    GHAssertNotEqualObjects(builer, self.builder, @"copy-objects should not be equal to objects");
}



@end



