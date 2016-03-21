//
//  MFWHttpTaskEngineTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/25.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"
#import "MFWHttpTaskEngine.h"
#import "MFWHttpTaskAFNEngine.h"
#import "MFWHttpDataTask.h"

/*
 MFWHttpTaskEngine - 用于创建engine并发起请求
 MFWHttpTaskEngineTest - 用于 创建多个engine 流水线测试 以及请求/上传/下载以及相关业务逻辑测试
 */

@interface MFWHttpTaskAFNEngine ()

@property (nonatomic,strong) NSMutableDictionary *repeatRequestFilter;

@end

@interface MFWHttpTaskAFNEngineTests : MFWHttpManagerTests <MFWHttpTaskObseverDelegate>

@end



@implementation MFWHttpTaskAFNEngineTests

- (void)setUpClass
{
    [super setUpClass];
}


/*
 目的:测试engine流水线创建方法： - (instancetype)initWithSingleIdentifier:(NSString *)identifier
 方式.1:identifier - 为@""时，判断是否是默认engine
 方式.2:identifier - 为nil时，判断是否是默认engine
 方式.3:identifier 创建成功后，再次创建一个engine时，两者是否相等
 方式.4:identifier 为defaultEngine 的identifier时，创建的对象是否是defaultEngine
 */

- (void)testInitEngineWithSingleIdentifierIsSuccess
{
//    MFWHttpTaskEngine *default_engine = [MFWHttpTaskEngine defaultEngine];
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@""];
//    GHAssertEqualObjects(engine, default_engine, @"engine identifier should set default identifier");
//  
//    engine = [MFWHttpTaskEngine engineWithSingleIdentifier:nil];
//    GHAssertEqualObjects(engine, default_engine, @"engine identifier should set default identifier");
//    
//    engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"test"];
//    MFWHttpTaskEngine *testEngine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"test"];
//    GHAssertEqualObjects(engine, testEngine, @"engine identifier is not an unique flag");
//    
//    engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"com.mafengwo.defaultAFNEngine"];
//    GHAssertEqualObjects(engine, default_engine, @"engine identifier should be default identifier");
//
//    engine = [MFWHttpTaskEngine new];
//    GHAssertNotEqualObjects(engine, default_engine, @"engine new should not be default identifier");
    
}

- (void)testPropertiesAreGetterCorrectly
{
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine defaultEngine];
//    MFWHttpDataTask *task = [MFWHttpDataTask taskWithURLString:self.test_request_url
//                                                method:HttpMethodGet
//                                                params:nil
//                                              taskType:0];
//    [engine executeTask:task complection:nil];
//    GHAssertTrue([engine.httpTasks containsObject:task], @"httpTasks is error in setter or getter");
}


#pragma mark - httpTasks 属性测试用例

- (MFWHttpDataTask *)createTestTask
{
    MFWHttpDataTask *task = [MFWHttpDataTask taskWithURLString:self.test_request_url
                                                method:HttpMethodGet
                                                params:@{}
                                              taskType:0];
    return task;
}



/*
 目的:测试engine 的 httpTasks 属性的业务逻辑的准确性 --- httpTasks包含所有的请求task
 方式.1:发起一个请求，判断在某个请求完后后，是否还持有task
 方式.2:发起一个请求，判断在某个请求完后后，是否还持有task
 方式.3:一个不允许重复的对象多次请求，判断列表个数是否递增
 方式.4:一个允许重复的对象多次请求，判断列表个数是否递增
 方式.5:多次发起一个请求，判断列表个数是否在递增
 方式.6:多次发起允许重复的请求，判断列表个数是否在递增
 */
- (void)testHttpTasksListValue
{
    
//    MFWHttpTaskEngine *testEngine1 = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testHttpTasksListValue.1"];
//    MFWHttpDataTask *task = [self createTestTask];
//    __block  BOOL taskIsComplecton = NO;
//    [testEngine1 executeTask:task
//                complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                    taskIsComplecton = YES;
//                }];
//    GHRunForInterval(4.0);
//    GHAssertTrue(taskIsComplecton, @"");
//    GHRunForInterval(0.5);
//    GHAssertFalse([testEngine1.httpTasks containsObject:task], @"httpTasks 应该不再持有已请求完成的task");
//    
//    task = [self createTestTask];
//    task.observerDelegate = self;
//    [testEngine1 executeTask:task complection:nil];
//    GHAssertTrue([testEngine1.httpTasks containsObject:task], @"httpTasks 应该持有在完成后重复请求的task");
//    
//    //一个不允许重复的对象多次请求测试
//    MFWHttpTaskEngine *testEngine2 = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testHttpTasksListValue.2"];
//    
//    MFWHttpDataTask *otherTask = [self createTestTask];
//    [testEngine2 executeTask:otherTask complection:nil];
//    NSInteger count = testEngine2.httpTasks.count;
//    
//    [testEngine2 executeTask:otherTask complection:nil];
//    [testEngine2 executeTask:otherTask complection:nil];
//    NSInteger count_1 = testEngine2.httpTasks.count;
//    GHAssertTrue(count == count_1, @"一个对象多次发起请求，task 应该只添加一次");
//    
//    //一个允许重复的对象多次请求测试
//    MFWHttpTaskEngine *testEngine3 = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testHttpTasksListValue.3"];
//    MFWHttpDataTask *anotherTask = [self createTestTask];
//    anotherTask.allowRepeat = YES;
//    [testEngine3 executeTask:anotherTask complection:nil];
//    NSInteger another_count = testEngine3.httpTasks.count;
//    
//    [testEngine3 executeTask:anotherTask complection:nil];
//    [testEngine3 executeTask:anotherTask complection:nil];
//    NSInteger another_count_1 = testEngine3.httpTasks.count;
//    GHAssertTrue(another_count == another_count_1,
//                 @"一个允许重复的对象多次发起请求，task 应该只添加一次");
//    
//    //多次发起一个请求测试
//    MFWHttpTaskEngine *testEngine4 = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testHttpTasksListValue.4"];
//    MFWHttpDataTask *task4 = [self createTestTask];
//    [testEngine4 executeTask:task4 complection:nil];
//    NSInteger count4 = testEngine4.httpTasks.count;
//    
//    MFWHttpDataTask *task4_1 = [self createTestTask];
//    [testEngine4 executeTask:task4_1 complection:nil];
//    
//    MFWHttpDataTask *task4_2 = [self createTestTask];
//    [testEngine4 executeTask:task4_2 complection:nil];
//    NSInteger count4_1 = testEngine4.httpTasks.count;
//    
//    GHAssertTrue(count4 == (count4_1 -2 ),
//                 @"多次发起一个请求（默认不允许重复），应该包含所有task");
//
//    //多次发起允许重复的请求测试
//    MFWHttpTaskEngine *testEngine5 = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testHttpTasksListValue.5"];
//    MFWHttpDataTask *task5 = [self createTestTask];
//    task5.allowRepeat = YES;
//    [testEngine5 executeTask:task5 complection:nil];
//    NSInteger count5 = testEngine5.httpTasks.count;
//    
//    MFWHttpDataTask *task5_1 = [self createTestTask];
//    task5_1.allowRepeat = YES;
//    [testEngine5 executeTask:task5_1 complection:nil];
//    
//    MFWHttpDataTask *task5_2 = [self createTestTask];
//    [testEngine5 executeTask:task5_2 complection:nil];
//    NSInteger count5_1 = testEngine5.httpTasks.count;
//    
//    GHAssertTrue(count5 == (count5_1 - 2 ),
//                 @"多次发起一个允许重复的请求，应该包含所有task");
    
}


- (void)httpTaskStartedSucceeded:(MFWHttpDataTask*)task
{
//    MFWHttpTaskEngine *testEngine1 = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testHttpTasksListValue.1"];
//    GHAssertTrue(![testEngine1.httpTasks containsObject:task], @"httpTasks-- 应该不再持有已请求完成的task");
}



#pragma mark - repeatRequestFilter  engine 当前执行队列测试

/*
 目的:测试engine的 私有属性 repeatRequestFilter
 方式.1:发起一个请求，判断执行队列是否包含该请求
 方式.2:发起一个允许重复的请求，判断执行队列是否包含该请求
 方式.3:多次发起一个请求，判断执行队列列表个数是否在再次发起的相同请求时递增
 方式.4:多次发起允许重复的请求，判断执行队列列表个数是否包含再次发起的相同请求
 */
- (void)testRepeatRequestFilter
{
//    MFWHttpTaskAFNEngine *testEngine1 = (MFWHttpTaskAFNEngine *)[MFWHttpTaskEngine engineWithSingleIdentifier:@"testRepeatRequestFilter.1"];
//    MFWHttpDataTask *testTask = [self createTestTask];
//    [testEngine1 executeTask:testTask complection:nil];
//    NSArray *valueList = [testEngine1.repeatRequestFilter allKeys];
//    GHAssertTrue([valueList containsObject:testTask.identifier],
//                 @"执行队列应该包含已发起的一个请求");
//    //
//    testTask = [self createTestTask];
//    testTask.allowRepeat = YES;
//    [testEngine1 executeTask:testTask complection:nil];
//    GHAssertTrue([[testEngine1.repeatRequestFilter allKeys] containsObject:testTask.identifier],
//                 @"执行队列应该包含已发起的一个允许重复请求");
//    
//    //多次不允许重复请求
//    MFWHttpTaskAFNEngine *testEngine2 = (MFWHttpTaskAFNEngine *)[MFWHttpTaskEngine engineWithSingleIdentifier:@"testRepeatRequestFilter.2"];
//    testTask = [self createTestTask];
//    [testEngine2 executeTask:testTask complection:nil];
//    NSInteger engine2_count = [[testEngine2.repeatRequestFilter allKeys] count];
//    
//    MFWHttpDataTask *testTask1 = [self createTestTask];
//    [testEngine2 executeTask:testTask1 complection:nil];
//    NSInteger engine2_count_1 = [[testEngine2.repeatRequestFilter allKeys] count];
//    GHAssertTrue(engine2_count == engine2_count_1, @"在一个请求未完成期间，执行队列不应该包含再次发起的不允许重复的相同请求");
//    
//    //多次允许
//    testTask = [self createTestTask];
//    [testEngine1 executeTask:testTask complection:nil];
//    
//    testTask1 = [self createTestTask];
//    testTask1.allowRepeat = YES;
//    [testEngine1 executeTask:testTask1 complection:nil];
//    GHAssertTrue([[testEngine1.repeatRequestFilter allKeys] containsObject:testTask1.identifier],
//                 @"在一个请求未完成期间，执行队列应该包含再次发起的允许重复的相同请求");
}


#pragma mark - executeTask:complection: 方法测试用例

/*
 目的:测试engine的 - (void)executeTask:(MFWHttpTask *)httpTask
 complection:(MFWHttpTaskCompletion)completion 方法的正确性
 方式.1:发起一个普通请求，判断请求complection 是否执行
 */
- (void)testExecuteTaskIsCorrectly
{
//    __block BOOL isComplection = NO;
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine defaultEngine];
//    MFWHttpDataTask *task = [self createTestTask];
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                isComplection = YES;
//            }];
//    
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"请求complection block 未执行");
//    //
//    task.request.URLString = nil;
//    __block BOOL isComplection_urlNone = NO;
//    [engine executeTask:task complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//        isComplection_urlNone = YES;
//    }];
//    
//    GHRunForInterval(2.0);
//    GHAssertFalse(isComplection_urlNone, @"URL 资源为空时，task不应该执行");
}


/*
 目的:测试engine的 - (void)executeTask:(MFWHttpTask *)httpTask
 complection:(MFWHttpTaskCompletion)completion 方法的健壮性
 方式.1:当task 为空时，判断是否crash
 方式.2:当completion 为空时，判断是否crash
 */
- (void)testExecuteTaskIsStrongly
{
//    MFWHttpTaskAFNEngine *engine = (MFWHttpTaskAFNEngine *)[MFWHttpTaskEngine defaultEngine];
//    
//    GHAssertNoThrow([engine executeTask:nil complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//        NSLog(@"is complection");
//    }], @"当task 为nil 时，不应该crash");
//    
//    MFWHttpDataTask *task = [self createTestTask];
//    GHAssertNoThrow([engine executeTask:task complection:nil], @"当complection 为nil 时，不应该crash");
//    //
//    GHAssertNoThrow([engine executeTask:nil complection:nil], @"当 task，complection 为nil 时，不应该crash");
}



/*
 目的:测试engine的 - (void)executeTask:(MFWHttpTask *)httpTask
 complection:(MFWHttpTaskCompletion)completion 方法的正确性
 方式:发起一个上传请求，判断请求返回responseData数据是否正确
 */
- (void)testExecuteUploadTaskIsCorrectly
{
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine defaultEngine];
//    MFWHttpTask *task = [MFWHttpTask taskWithURLString:@"http://172.18.20.193/upload.php" method:HttpMethodPost params:nil taskType:HttpTaskTypeUpload];
//  
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
//    task.uploadData = @{@"aaa": url,@"bbb":url,@"ccc":url};
//    
//    __block BOOL isComplection = NO;
//    [engine executeTask:task complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//        isComplection = YES;
//    }];
//    
//    task.progerssBlock = ^(MFWHttpTask *task,NSProgress *progress){
//        NSLog(@"上传了---->%f",progress.fractionCompleted);
//    };
}


/*
 目的:测试engine的 - (void)executeTask:(MFWHttpTask *)httpTask
 complection:(MFWHttpTaskCompletion)completion 方法的正确性
 方式:发起一个下载请求，判断请求返回responseData数据是否正确
 */
- (void)testExecuteDownloadTaskIsCorrectly
{
    
}



#pragma mark - cancelTask 方法测试用例

/*
 目的:测试engine的 - (void)cancelTask:(MFWHttpTask *)httpTask; 方法的健壮性
 方式.1:当task 为空时，判断取消是否crash
 方式.2:当task 不在执行队列时，判断取消是否crash
 */

- (void)testCancelTaskIsStrongly
{
//    MFWHttpTaskAFNEngine *engine = (MFWHttpTaskAFNEngine *)[MFWHttpTaskEngine defaultEngine];
//    GHAssertNoThrow([engine cancelTask:nil],@"task 为nil是，不应该crash");
//    //
//    MFWHttpDataTask *task = [self createTestTask];
//    GHAssertNoThrow([engine cancelTask:task],@"task不在执行队列时，取消task，不应该crash");
//    GHAssertTrue(task.taskStatus == HttpTaskStatusNone, @"task不在执行队列时，取消task不应该有状态改变");
//    GHAssertFalse([[engine.repeatRequestFilter allKeys] containsObject:task], @"task不在执行时，取消task不应该引入其他的对象");
}


/*
 目的:测试engine的 - (void)cancelTask:(MFWHttpTask *)httpTask; 方法的正确性
 方式:当取消task 时，判断task 状态是否取消，判断complection 取消标识是否标记，判断httpTasks 是否删除成功
 方式.1: 当在结束后cancel task ，判断当前task状态
 */
- (void)testCancelTaskIsSuccessed
{
//    MFWHttpTaskEngine *engine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"testCancelTaskIsSuccessed.test"];
//    MFWHttpDataTask *task = [self createTestTask];
//    __block BOOL isComplection = NO;
//    [engine executeTask:task
//            complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error){
//                isComplection = YES;
//    }];
//    GHRunForInterval(2.0);
//    GHAssertTrue(isComplection, @"");
//    
//    GHRunForInterval(0.5);
//    NSLog(@"complection is ---- %d----%d",isComplection,[engine.httpTasks containsObject:task]);
//    
//    [engine cancelTask:task];
//    GHAssertTrue(task.taskStatus != HttpTaskStatusCanceled, @"在task 请求完成后，取消task，task 的状态不应该是canceled");
    
}



#pragma mark - cancelAllTask 方法测试用例
/*
 目的:测试engine的 - (void)cancelAllTask; 方法的正确性
 方式:当取消全部task 时，判断task 状态是否取消，判断complection 取消标识是否标记，判断httpTasks 是否删除成功
 */
- (void)testCancelAllTasksAreSuccessed
{
//    MFWHttpTaskAFNEngine *engine = (MFWHttpTaskAFNEngine *)[MFWHttpTaskEngine engineWithSingleIdentifier:@"testCancelAllTasksAreSuccessed"];
//    MFWHttpDataTask *task = [self createTestTask];
//    [engine executeTask:task complection:nil];
//    [engine cancelAllTask];
//    
//    GHAssertTrue(task.taskStatus == HttpTaskStatusCanceled, @"task应该标记为取消状态");
//    
//    GHAssertFalse([[engine.repeatRequestFilter allKeys] containsObject:task.identifier], @"task取消后，执行队列不应该再包含该task");
//    GHAssertFalse(engine.httpTasks.count == 0, @"全部取消后，task列表应该为空");
}



/*
 目的:测试engine的 - (void)cancelAllTask; 方法的健壮性
 方式:当engine 里无task时，取消全部task 是否crash
 */
- (void)testCancelAllTasksIsStrongly
{
//    MFWHttpTaskAFNEngine *engine = (MFWHttpTaskAFNEngine *)[MFWHttpTaskEngine defaultEngine];
//    GHAssertNoThrow([engine cancelAllTask],@"无task 执行列表时，不应该crash");
}




- (void)tearDownClass
{
    
}

@end





