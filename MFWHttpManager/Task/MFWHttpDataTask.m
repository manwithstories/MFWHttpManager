//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpDataTask.h"
#import "MFWRequest.h"
#import "MFWResponse.h"
#import "MFWHttpTaskAFNEngine.h"
#import "MFWHttpManager.h"

#define MFWHttpTaskIdentifierSeparator @"$#@#$"

@interface MFWHttpDataTask() {
    __weak MFWHttpTaskEngine *_engine;
}

@property (nonatomic,readonly,copy) NSString *resourceId;

- (void)weak_setHttpEngine:(MFWHttpTaskEngine *)engine;

@end

@implementation MFWHttpDataTask

@synthesize response = _response;
@synthesize identifier = _identifier;
@synthesize resourceId = _resourceId;

- (void)weak_setHttpEngine:(MFWHttpTaskEngine *)engine
{
    _engine = engine;
}

- (void)cancel
{
    [_engine cancelTask:self];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _taskCachePolicy = MFWHttpTaskNeedCache;
        _taskType = MFWHttpTaskTypeRequest;
        _request = [MFWRequest new];
    }
    return self;
}

- (MFWHttpTaskType)taskType
{
    if (_taskType < MFWHttpTaskTypeRequest)
    {
        _taskType = MFWHttpTaskTypeRequest;
    }
    else if (_taskType > MFWHttpTaskTypeUpload)
    {
        _taskType = MFWHttpTaskTypeRequest;
    }
    return _taskType;
}


- (MFWHttpTaskCachePolicy)taskCachePolicy
{
    if (_taskCachePolicy < MFWHttpTaskNeedCache)
    {
        _taskCachePolicy = MFWHttpTaskNeedCache;
    }
    else if (_taskCachePolicy > MFWHttpTaskIgnoreCache)
    {
        _taskCachePolicy = MFWHttpTaskNeedCache;
    }
    return _taskCachePolicy;
}


#pragma mark - task


+ (MFWHttpDataTask *)taskWithURLString:(NSString *)urlString
                                method:(MFWRequestHttpMethod)method
                                params:(NSDictionary *)params
                              taskType:(MFWHttpTaskType)taskType
{
    MFWHttpDataTask *task = [[MFWHttpDataTask alloc] init];
    
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:urlString
                                       method:method
                                       params:params];
    task.request = request;
    task.taskType = taskType;
    return task;
}


#pragma mark - load cache data
//读取缓存数据
- (void)loadCacheDataWithCompleton:(MFWHttpTaskCacheCompletion)completion
{
    if (self.cacheHandler && [self.cacheHandler respondsToSelector:@selector(loadTask:cacheDataId:completion:)])
    {
        [self.cacheHandler loadTask:self
                        cacheDataId:self.resourceId
                         completion:completion];
    }
}

//清理缓存数据
- (BOOL)cleanCacheData
{
    if (self.cacheHandler && [self.cacheHandler respondsToSelector:@selector(cleanTask:cacheDataId:)])
    {
        return [self.cacheHandler cleanTask:self
                                cacheDataId:self.resourceId];
    }
    return NO;
}


#pragma mark - override Getter resourceId
//根据 MFWHttpTask 返回对应的资源ID 规则是 url+httpMethod+params 做base64
- (NSString *)resourceId
{
    if([_resourceId length]<1){
        NSString *str = [NSString stringWithFormat:@"%@%lu%@%@",self.request.URLString,(unsigned long)self.request.httpMethod,self.request.params,self.requestSupportGzip?@"gzip":@""];
        
        NSString *dataID =  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSData *data = [dataID dataUsingEncoding:NSUTF8StringEncoding];
        NSString *resourceId = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        _resourceId = resourceId;
    }
    return _resourceId;
}

#pragma mark - override identifier
- (NSString *)identifier
{
    if([_identifier length] == 0)
    {
        if(self.allowRepeat)
        {
            static NSDateFormatter *dateformatter = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dateformatter = [[NSDateFormatter alloc] init];
                [dateformatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
            });
            
            NSString *timeNow = [dateformatter stringFromDate:[NSDate date]];
            _identifier = [NSString stringWithFormat:@"%@%@%@%@%d",self.resourceId,MFWHttpTaskIdentifierSeparator,timeNow,MFWHttpTaskIdentifierSeparator,(arc4random() % INT_MAX)];
        }
        else
        {
            _identifier = self.resourceId;
        }
    }
    return _identifier;
}

#pragma mark - override getter allowRepeat
- (BOOL)allowRepeat
{
    if(self.taskType == MFWHttpTaskTypeUpload){
        return YES;
    }else{
        return _allowRepeat;
    }
}

#pragma mark override setter
- (void)setSaveDownloadFilePath:(NSString *)saveDownloadFilePath
{
    _saveDownloadFilePath = saveDownloadFilePath;
    if([saveDownloadFilePath length]>1){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:saveDownloadFilePath]){
          NSError *error =nil;
          [fileManager createDirectoryAtPath:saveDownloadFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
}

#pragma mark - override setter taskStatus
- (void)setTaskStatus:(MFWHttpTaskStatus)taskStatus
{
    _taskStatus = taskStatus;
    switch (_taskStatus) {
        case MFWHttpTaskStatusAdded:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskAdded:)]){
                [self.observerDelegate httpTaskStarted:self];
            }
        }
            break;
        case MFWHttpTaskStatusStarted:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskStarted:)]){
                [self.observerDelegate httpTaskStarted:self];
            }
        }
            break;
        case MFWHttpTaskStatusSucceeded:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskStartedSucceeded:)]){
                [self.observerDelegate httpTaskStartedSucceeded:self];
            }
            
            if(self.taskType == MFWHttpTaskTypeRequest)
            {
                if(self.cacheHandler != nil &&
                   [self.cacheHandler respondsToSelector:@selector(saveTask:cacheData:dataId:)])
                {
                    [self.cacheHandler saveTask:self
                                      cacheData:self.response.responseData
                                         dataId:self.resourceId];
                }
            }
            
            if(self.taskType == MFWHttpTaskTypeDownload)
            {
                if(self.cacheHandler != nil &&
                   [self.cacheHandler respondsToSelector:@selector(saveTask:downloadFile:dataId:)]){
                    [self.cacheHandler saveTask:self
                                   downloadFile:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",self.saveDownloadFilePath,self.saveDownloadFileName]]
                                         dataId:self.resourceId];
                }
            }
            
            // 清空engine
            [self weak_setHttpEngine:nil];
        }
            break;
        case MFWHttpTaskStatusFailed:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskStartedFailed:withError:)]){
                [self.observerDelegate httpTaskStartedFailed:self withError:self.error];
            }
            
            // 清空engine
            [self weak_setHttpEngine:nil];
        }
            break;
        case MFWHttpTaskStatusCancelled:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskCancelled:)]){
                [self.observerDelegate httpTaskCancelled:self];
            }
            
            // 清空engine
            [self weak_setHttpEngine:nil];
        }
            break;
        
        default:
        {
            MFWHttpManagerAssert(NO, @"MFWHttpTask cant't have  a unknown State");
        }
            break;
    }
}

@end

@implementation MFWHttpDataTask (MFWQuickInit)

+ (MFWHttpDataTask *)requestTaskWithURLString:(NSString *)urlString
                                       method:(MFWRequestHttpMethod)method
                                       params:(NSDictionary *)params
{
    return [self taskWithURLString:urlString method:method params:params taskType:MFWHttpTaskTypeRequest];
}

+ (MFWHttpDataTask *)uploadTaskWithURLString:(NSString *)urlString
                                      method:(MFWRequestHttpMethod)method
                                      params:(NSDictionary *)params;
{
    return [self taskWithURLString:urlString method:method params:params taskType:MFWHttpTaskTypeUpload];
}

+ (MFWHttpDataTask *)downloadTaskWithURLString:(NSString *)urlString
                                        method:(MFWRequestHttpMethod)method
                                        params:(NSDictionary *)params;
{
    return [self taskWithURLString:urlString method:method params:params taskType:MFWHttpTaskTypeDownload];
}

@end
