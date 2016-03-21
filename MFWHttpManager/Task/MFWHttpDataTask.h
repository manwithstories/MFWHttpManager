//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFWRequest.h"
#import "MFWResponse.h"
#import "HttpRequestBuildProtocol.h"
#import "HttpResponseHandleProtocol.h"

@class MFWHttpDataTask;
@class MFWResponseBaseHandler;
@class MFWRequestBaseBuilder;


typedef void(^MFWHttpTaskCompletion)(BOOL succeed,BOOL cancelled,id responeseData,NSError *error);
typedef void(^MFWHttpTaskProgerssBlock)(MFWHttpDataTask *task,NSProgress *progress);
typedef void(^MFWHttpTaskCacheCompletion)(NSData *cacheData,NSError *error);


typedef NS_ENUM(NSUInteger, MFWHttpTaskCachePolicy)
{
    MFWHttpTaskNeedCache = 0,
    MFWHttpTaskIgnoreCache
};

typedef NS_ENUM(NSUInteger, HttpTaskType)
{
    HttpTaskTypeRequest = 0,
    HttpTaskTypeDownload ,
    HttpTaskTypeUpload
};

/**
 * http请求状态
 */
typedef enum{
    HttpTaskStatusNone = 0 ,
    HttpTaskStatusAdded,
    HttpTaskStatusStarted,
    HttpTaskStatusSucceeded,
    HttpTaskStatusFailed,
    HttpTaskStatusCanceled
}HttpTaskStatus;

//cache protocol
@protocol MFWHttpTaskCacheDataProtocol <NSObject>

- (void)saveTask:(MFWHttpDataTask *)task
       cacheData:(NSData *)responseData
          dataId:(NSString *)identifier;

//???
- (void)saveTask:(MFWHttpDataTask *)task
    downloadFile:(NSURL *)filePath
          dataId:(NSString *)identifier;

- (void)loadTask:(MFWHttpDataTask *)task
     cacheDataId:(NSString *)identifier
      completion:(MFWHttpTaskCacheCompletion)completion;

- (BOOL)cleanTask:(MFWHttpDataTask *)task
      cacheDataId:(NSString *)identifier;

@end

/**
 * 网络任务请求过程监听器，如果设置此监听，数据要监听者自已处理
 */
@protocol MFWHttpTaskObseverDelegate <NSObject>

@optional

- (void)httpTaskAdded:(MFWHttpDataTask*)task;
- (void)httpTaskStarted:(MFWHttpDataTask*)task;
- (void)httpTaskCancelled:(MFWHttpDataTask*)task;
- (void)httpTaskStartedSucceeded:(MFWHttpDataTask*)task;
- (void)httpTaskStartedFailed:(MFWHttpDataTask*)task withError:(NSError *)error;

@end

/* 
 MFWHttpTask - 封装一个接口请求任务，包括接口请求与响应。
 MFWHttpRequest - 封装一个完整的接口请求
 MFWHttpResponse - 封装一个完整的接口响应
 taskIdentifier - 接口请求任务的唯一标识
 
 taskType - 请求类型
 taskCachePolicy - 请求是否缓存
 */

@interface MFWHttpDataTask : NSObject

//request封装对象
@property (nonatomic, strong) MFWRequest *request;

//response封装对象
@property (nonatomic, strong, readonly) MFWResponse *response;   

@property (nonatomic, strong) NSError *error;

//任务类型
@property (nonatomic, assign) HttpTaskType taskType;

//是否缓存
@property (nonatomic, assign) MFWHttpTaskCachePolicy taskCachePolicy;

//task 状态
@property (nonatomic, assign, readonly) HttpTaskStatus taskStatus;


//请求处理插件
@property (nonatomic,  copy) id <HttpRequestBuildProtocol> requestPlugin;

//响应解析插件
@property (nonatomic,  copy) id <HttpResponseHandleProtocol> responsePlugin;

//cache代理
@property (nonatomic, copy) id <MFWHttpTaskCacheDataProtocol> cacheHandler;    //缓存处理插件

//监听状态的代理
@property (nonatomic,  weak) id <MFWHttpTaskObseverDelegate>observerDelegate;

//任务完成的Block
@property (nonatomic,  copy) MFWHttpTaskCompletion compBlock;

//进度条Block只在下载或者上传类型的MFWHttpTask才会有作用
@property (nonatomic,  copy) MFWHttpTaskProgerssBlock progerssBlock;

//获取task对应的资源ID - 对于同一个request配置项，ID相同
@property (nonatomic, readonly,copy) NSString *identifier;

//是否允许重复请求 - 默认不允许，允许的情况下，一个request配置项，ID 不同
@property (nonatomic, assign) BOOL allowRepeat;

 //为你需要上传的文件指定  name (mutliPart协议规定多文件上传要指定name 以帮助服务器做资源区分) 和 NSURL（本地文件路径）
@property (nonatomic, strong) NSDictionary<NSString *, NSURL *> *uploadData;

//如果是下载任务的时候 为你的下载的文件指定一个保存的路径,不能为空否则下载的文件不会被保存,如果这个目录不存在会自动为你创建该目录
@property (nonatomic, copy) NSString *saveDownloadFilePath;

//如果是下载任务的时候 为你的下载的文件指定一个保存的文件名,如果为空则会用服务器的资源名代替。
@property (nonatomic, copy) NSString *saveDownloadFileName;


/*
 一个普通请求(MFWHttpTaskTypeRequest)任务的基本参数封装，返回task 对象
 注意：此方法返回的task对象并未开始请求
 使用方式：可以用于简单的请求任务，也可以作为基础task 创建，再后续增补属性
 */
+ (MFWHttpDataTask *)taskWithURLString:(NSString *)urlString
                            method:(HttpMethod)method
                            params:(NSDictionary *)params
                            taskType:(HttpTaskType)taskType;



#pragma mark -  load cache

//读取缓存数据
- (void)loadCacheDataWithComplecton:(MFWHttpTaskCacheCompletion)completion;


//清理缓存数据
- (BOOL)cleanCacheData;


@end




