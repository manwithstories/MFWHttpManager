//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpTask.h"
#import "MFWHttpRequest.h"
#import "MFWHttpResponse.h"
#import "MFWHttpTaskAFNEngine.h"

#define separator @"$#@#$"

@interface MFWHttpTask()
@property (nonatomic,readonly,copy) NSString *resourceId;
@end

@implementation MFWHttpTask
@synthesize response = _response;
@synthesize identifier = _identifier;
@synthesize resourceId = _resourceId;


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _taskCachePolicy = MFWHttpTaskNeedCache;
        _request = [MFWHttpRequest new];
        
    }
    return self;
}


- (NSString *)taskTypeString
{
    NSString *type = nil;
    switch (self.taskType)
    {
        case HttpTaskTypeRequest:
            type = @"Request";
            break;
        case HttpTaskTypeUpload:
            type = @"Upload";
            break;
        case HttpTaskTypeDownload:
            type = @"Download";
            break;
        default:
            break;
    }
    return type;
}


#pragma mark - task


+ (MFWHttpTask *)taskWithURLString:(NSString *)urlString
                            method:(HttpMethod)method
                            params:(NSDictionary *)params
                            taskType:(HttpTaskType)taskType
{
    MFWHttpTask *task = [[MFWHttpTask alloc] init];
    task.taskType = HttpTaskTypeRequest;
    
    MFWHttpRequest *request =
    [[MFWHttpRequest alloc] initWithURLString:urlString
                                       method:method
                                       params:params];
    task.request = request;
    task.taskType = taskType;
    return task;
}



#pragma mark - load cache data
//读取缓存数据
- (void)loadCacheDataWithComplecton:(MFWHttpTaskCacheCompletion)completion
{
    if (self.cacheHandler && [self.cacheHandler respondsToSelector:@selector(loadCacheDataWithDataId:completion:)])
    {
         [self.cacheHandler loadCacheDataWithDataId:self.resourceId completion:completion];
    }
}

//清理缓存数据
- (BOOL)cleanCacheData
{
    if (self.cacheHandler && [self.cacheHandler respondsToSelector:@selector(cleanCacheDataWithDataId:)])
    {
        return [self.cacheHandler cleanCacheDataWithDataId:self.resourceId];
    }
    return NO;
}


#pragma mark - override Getter resourceId
//根据 MFWHttpTask 返回对应的资源ID 规则是 url+httpMethod+params 做base64
- (NSString *)resourceId
{
    if([_resourceId length]<1){
        NSString *str = [NSString stringWithFormat:@"%@%lu%@",self.request.URLString,(unsigned long)self.request.httpMethod,self.request.params];
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
    if([_identifier length]<1){
        if(self.allowRepeat){
            NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
            NSString *timeNow = [dateformatter stringFromDate:[NSDate date]];
            _identifier = [NSString stringWithFormat:@"%@%@%@%@%d",self.resourceId,separator,timeNow,separator,(arc4random() % INT_MAX)];
        }else{
            _identifier = self.resourceId;
        }
    }
    return _identifier;
}

#pragma mark - override getter allowRepeat
- (BOOL)allowRepeat
{
    if(self.taskType == HttpTaskTypeUpload){
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
- (void)setTaskStatus:(HttpTaskStatus)taskStatus
{
    _taskStatus = taskStatus;
    switch (_taskStatus) {
        case HttpTaskStatusAdded:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskAdded:)]){
                [self.observerDelegate httpTaskStarted:self];
            }
        }
            break;
        case HttpTaskStatusStarted:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskStarted:)]){
                [self.observerDelegate httpTaskStarted:self];
            }
        }
            break;
        case HttpTaskStatusSucceeded:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskStartedSucceeded:)]){
                [self.observerDelegate httpTaskStartedSucceeded:self];
            }
            
            if(self.taskType == HttpTaskTypeRequest){
                if(self.cacheHandler != nil && [self.cacheHandler respondsToSelector:@selector(saveCacheData:dataId:)]){
                    [self.cacheHandler saveCacheData:self.response.responseData dataId:self.resourceId];
                }
            }
            
            if(self.taskType == HttpTaskTypeDownload){
                if(self.cacheHandler != nil && [self.cacheHandler respondsToSelector:@selector(saveDownloadFile:dataId:)]){
                    [self.cacheHandler saveDownloadFile: [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",self.saveDownloadFilePath,self.saveDownloadFileName]] dataId:self.resourceId];
                }
            }
        }
            break;
        case HttpTaskStatusFailed:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskStartedFailed:withError:)]){
                [self.observerDelegate httpTaskStartedFailed:self withError:self.error];
            }
        }
            break;
        case HttpTaskStatusCanceled:
        {
            if(self.observerDelegate != nil && [self.observerDelegate respondsToSelector:@selector(httpTaskCancelled:)]){
                [self.observerDelegate httpTaskCancelled:self];
            }
        }
            break;
        
        default:
        {
            NSAssert(NO, @"MFWHttpTask cant't have  a unkonow State");
        }
            break;
    }
}

@end
