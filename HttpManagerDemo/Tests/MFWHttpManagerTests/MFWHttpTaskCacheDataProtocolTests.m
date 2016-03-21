//
//  MFWHttpTaskCacheDataProtocolTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/29.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "MFWHttpDataTask.h"

/*
 MFWHttpTaskCacheDataProtocol - task 的缓存协议
 MFWHttpTaskCacheDataProtocolTests - 用来测试协议方法参数的准确性以及执行情况
 */

@interface MFWHttpTaskCacheDataProtocolTests : GHTestCase

@end



@implementation MFWHttpTaskCacheDataProtocolTests


- (void)setUpClass
{
    
}

- (void)setUp
{
    
}

/*
 目的：测试 MFWHttpTaskCacheDataProtocol 的 
 - (void)saveTask:(MFWHttpTask *)task cacheData:(NSData *)responseData dataId:(NSString *)identifier;
 方法参数的准确行
  方式：创建task 对象，实现缓存协议，发起普通请求
 */
- (void)testProtocolOfSaveTaskCacheDataWithDataId
{
    
}

/*
 目的：测试 MFWHttpTaskCacheDataProtocol 的 - (void)saveTask:(MFWHttpTask *)task downloadFile:(NSURL *)filePath dataId:(NSString *)identifier; 方法参数的准确行
 方式：创建task 对象，实现缓存协议，发起下载请求
 */
- (void)testProtocolOfSaveTaskDownloadFileWithDataId
{
    
}

/*
 目的：测试 MFWHttpTaskCacheDataProtocol 的 - (void)loadTask:(MFWHttpTask *)task cacheDataId:(NSString *)identifier completion:(MFWHttpTaskCacheCompletion)completion; 方法参数的准确行
 方式.1:加载task 缓存数据
 方式.2:创建task 直接读取缓存数据
 方式.3:task为空时或ID为空时，直接读取缓存数据
 */
- (void)testProtocolOfLoadTaskCatchDataWithDataId
{
    
}


/*
 目的：测试 MFWHttpTaskCacheDataProtocol 的 - (void)loadTask:(MFWHttpTask *)task cacheDataId:(NSString *)identifier completion:(MFWHttpTaskCacheCompletion)completion; 方法参数的准确行
 方式.1：清除task 缓存数据
 方式.2: task 为空时清除缓存
 方式.3: id 为空时清除缓存
 */
- (void)testProtocolOfCleanTaskDataWithDataId
{
    
}



-(void)tearDown
{
    
}


-(void)tearDownClass
{
    
}

@end