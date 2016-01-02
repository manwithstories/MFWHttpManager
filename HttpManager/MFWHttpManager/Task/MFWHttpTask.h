//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFWHttpRequest.h"
#import "MFWHttpResponse.h"
#import "HttpRequestBuildProtocol.h"
#import "HttpResponseHandleProtocol.h"

@class MFWHttpTask;
@class MFWResponseBaseHandler;
@class MFWRequestBaseBuilder;


typedef void(^MFWHttpTaskCompletion)(BOOL succeed,BOOL cancelled,id responeseData,NSError *error);
typedef void(^MFWHttpTaskProgerssBlock)(MFWHttpTask *task,NSProgress *progress);
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
    HttpTaskStatusAdded =     0,
    HttpTaskStatusStarted =   1,
    HttpTaskStatusSucceeded = 2,
    HttpTaskStatusFailed =    3,
    HttpTaskStatusCanceled =  4
}HttpTaskStatus;

//cache protocol
@protocol MFWHttpTaskCacheDataProtocol <NSObject>

- (void)saveCacheData:(NSData *)responseData dataId:(NSString *)identifier;

- (void)saveDownloadFile:(NSURL *)filePath dataId:(NSString *)identifier;

- (void)loadCacheDataWithDataId:(NSString *)identifier
                  completion:(MFWHttpTaskCacheCompletion)completion;

- (BOOL)cleanCacheDataWithDataId:(NSString *)identifier;

@end

/**
 * 网络任务请求过程监听器，如果设置此监听，数据要监听者自已处理
 */
@protocol MFWHttpTaskObseverDelegate <NSObject>

@optional

- (void)httpTaskAdded:(MFWHttpTask*)task;
- (void)httpTaskStarted:(MFWHttpTask*)task;
- (void)httpTaskCancelled:(MFWHttpTask*)task;
- (void)httpTaskStartedSucceeded:(MFWHttpTask*)task;
- (void)httpTaskStartedFailed:(MFWHttpTask*)task withError:(NSError *)error;

@end

/* 
 MFWHttpTask - 封装一个接口请求任务，包括接口请求与响应。
 MFWHttpRequest - 封装一个完整的接口请求
 MFWHttpResponse - 封装一个完整的接口响应
 taskIdentifier - 接口请求任务的唯一标识
 
 taskType - 请求类型
 taskCachePolicy - 请求是否缓存
 */

@interface MFWHttpTask : NSObject

@property (nonatomic, strong) NSError *error;

//request封装对象
@property (nonatomic, strong) MFWHttpRequest *request;

//response封装对象
@property (nonatomic, strong, readonly) MFWHttpResponse *response;   

//任务类型
@property (nonatomic, assign) HttpTaskType taskType;

//是否缓存
@property (nonatomic, assign) MFWHttpTaskCachePolicy taskCachePolicy;

//task 状态
@property (nonatomic, assign) HttpTaskStatus taskStatus;


//请求处理插件
@property (nonatomic,   copy) id <HttpRequestBuildProtocol> requestPlugin;

//响应解析插件
@property (nonatomic,   copy) id <HttpResponseHandleProtocol> responsePlugin;


//cache代理
@property (nonatomic,  weak) id <MFWHttpTaskCacheDataProtocol> cacheHandler;    //缓存处理插件

//监听状态的代理
@property (nonatomic,  weak) id <MFWHttpTaskObseverDelegate>observerDelegate;

//任务完成的Block
@property (nonatomic,  copy) MFWHttpTaskCompletion compBlock;

//进度条Block只在下载或者上传类型的MFWHttpTask才会有作用
@property (nonatomic,  copy) MFWHttpTaskProgerssBlock progerssBlock;

//获取对应的资源ID
@property (nonatomic, readonly,copy) NSString *identifier;

//是否允许重复请求
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
+ (MFWHttpTask *)taskWithURLString:(NSString *)urlString
                            method:(HttpMethod)method
                            params:(NSDictionary *)params
                            taskType:(HttpTaskType)taskType;



#pragma mark -  load cache

//读取缓存数据
- (void)loadCacheDataWithComplecton:(MFWHttpTaskCacheCompletion)completion;


//清理缓存数据
- (BOOL)cleanCacheData;


@end




