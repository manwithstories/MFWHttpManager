//
//  MFWHttpTaskTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/24.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"
#import "MFWHttpDataTask.h"

/*
 MFWHttpTask - 封装一个接口请求任务，包括接口请求与响应。
 MFWHttpTaskTests - 主要用来测试task对象属性的setter 和 getter方法的准确性以及枚举类型的边界测试
 */

@interface MFWHttpTaskTests : MFWHttpManagerTests

@end

//作为一个封装功能的对象。。。该测试什么呢。。。
@implementation MFWHttpTaskTests

- (void)setUpClass
{
    [super setUpClass];
}


/*
 目的: 测试task 的request 对象的属性，赋值正确
 方式: 创建task 对象并赋值，判断request 对象的输出值与输入值是否相等
 */
- (void)testRequestAreSetCorrectly
{
    MFWHttpDataTask *task =
    [MFWHttpDataTask taskWithURLString:self.test_request_url
                            method:HttpMethodGet
                            params:@{@"key":@"value"}
                          taskType:HttpTaskTypeRequest];
    
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:HttpMethodGet
                                       params:@{@"key":@"value"}];
    
    GHAssertEqualObjects(task.request.URLString, request.URLString, @"request property in task is error");
    GHAssertTrue(task.request.httpMethod == request.httpMethod, @"request property in task is error");
    GHAssertEqualObjects(task.request.params, request.params, @"request property in task is error");
}


- (void)testPropertiesAreGetterCorrectly
{
    MFWHttpDataTask *task =
    [MFWHttpDataTask taskWithURLString:self.test_request_url
                            method:HttpMethodGet
                            params:@{@"key":@"value"}
                          taskType:HttpTaskTypeUpload];

    GHAssertTrue(task.taskType == HttpTaskTypeUpload, @"taskType property is not set in init method");
    
}

- (void)testPropertiesAreSetterCorrectly
{
    MFWHttpDataTask *task = [MFWHttpDataTask new];
    task.taskType = HttpTaskTypeDownload;
    task.taskCachePolicy = MFWHttpTaskNeedCache;
    task.allowRepeat = YES;
    MFWHttpTaskCompletion complection = ^(BOOL succeed, BOOL cancelled, id responseData, NSError *error){
        NSLog(@"this is just test --- ");
    };
    task.compBlock = complection;
    //
    MFWHttpTaskProgerssBlock progress = ^(MFWHttpDataTask *task, NSProgress *progress)
    {
        NSLog(@"this is just test");
    };
    task.progerssBlock = progress;
    task.uploadData = @{@"name_0":[NSURL URLWithString:self.test_request_url]};
    task.uploadData = @{@"name_0":[NSURL URLWithString:@""]};

    ///
    GHAssertTrue(task.taskType == HttpTaskTypeDownload, @"taskType setter is error");
    GHAssertTrue(task.taskCachePolicy == MFWHttpTaskNeedCache, @"taskCachePolicy setter is error");
    GHAssertTrue(task.allowRepeat == YES, @"allowRepeat setter is error");
    GHAssertEqualObjects(task.compBlock, complection, @"compBlock setter is error");
    GHAssertEqualObjects(task.progerssBlock, progress, @"progerssBlock setter is error");
    GHAssertEqualObjects(task.uploadData[@"name_0"], [NSURL URLWithString:@""], @"uploadData setter is error");
    GHAssertTrue(task.uploadData.allKeys.count == 1, @"uploadData setter is error");
    
}

#pragma mark - taskType 类型边界测试
/*
 目的: MFWHttpTask对象 -  taskType 类型边界测试
 方式.1: 方法类型为-1时，判断方法类型是否是默认类型
 方式.2: 方法为1000时, 判断方法类型是否是默认类型
 */
- (void)testTaskTypeWhenOverFlow
{
    MFWHttpDataTask *task =
    [MFWHttpDataTask taskWithURLString:self.test_request_url
                            method:HttpMethodGet
                            params:@{@"key":@"value"}
                          taskType:-1];
    GHAssertTrue(task.taskType == HttpTaskTypeRequest, @"taskType should have default value");
    
    task.taskType = 1000;
    GHAssertTrue(task.taskType == HttpTaskTypeRequest, @"taskType should have default value");
}


#pragma mark - taskCachePolicy 类型边界测试
/*
 目的: MFWHttpTask对象 -  taskCachePolicy 类型边界测试
 方式.1: 方法类型为-1时，判断方法类型是否是默认类型
 方式.2: 方法为1000时, 判断方法类型是否是默认类型
 */
- (void)testTaskCachePolicyWhenOverFlow
{
    MFWHttpDataTask *task = [MFWHttpDataTask new];
    task.taskCachePolicy = -2;
    GHAssertTrue(task.taskCachePolicy == MFWHttpTaskNeedCache, @"taskCachePolicy should have default value");
    
    task.taskCachePolicy = 200;
    GHAssertTrue(task.taskCachePolicy == MFWHttpTaskNeedCache, @"taskCachePolicy should have default value");
}



//TODO: 对于加载缓存以及清理缓存的单元测试，先不加

////- (void)testLoadCacheDataIsExecutedCorrectly
//- (void)testWaittingTestForLoadCache
//{
//    
//}
//
//
////- (void)testCleanCacheDataIsExecutedCorrectly
//- (void)testWaittingTestForCleanCache
//
//{
//    
//}



- (void)tearDown
{
    
}



- (void)tearDownClass
{
    
}

@end

