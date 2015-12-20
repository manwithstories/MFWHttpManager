//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpTask.h"
#import "MFWHttpRequest.h"
#import "MFWHttpResponse.h"
#import "MFWHttpTaskAFNEngine.h"

#define separator @"$#+#$"

@interface MFWHttpTask ()
@end

@implementation MFWHttpTask
@synthesize response = _response;
@synthesize resourceID = _resourceID;

- (void)dealloc
{
    NSLog(@"%@ 释放了",self);
}

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
         [self.cacheHandler loadCacheDataWithDataId:self.allowRepeat?[self.resourceID componentsSeparatedByString:separator][0]:self.resourceID completion:completion];
    }
}

//清理缓存数据
- (BOOL)cleanCacheData
{
    if (self.cacheHandler && [self.cacheHandler respondsToSelector:@selector(cleanCacheDataWithDataId:)])
    {
        return [self.cacheHandler cleanCacheDataWithDataId:self.allowRepeat?[self.resourceID componentsSeparatedByString:separator][0]:self.resourceID];
    }
    return NO;
}


#pragma mark - 根据 MFWHttpTask 返回对应的资源ID 规则是 url+httpMethod+params 做base64
- (NSString *)resourceID
{
    if([_resourceID length]<1){
        NSString *str = [NSString stringWithFormat:@"%@%lu%@",self.request.URLString,(unsigned long)self.request.httpMethod,self.request.params];
        NSString *dataID =  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSData *data = [dataID dataUsingEncoding:NSUTF8StringEncoding];
        NSString *resourceId = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        _resourceID = resourceId;
        if(self.allowRepeat){
            NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
            NSString *timeNow = [dateformatter stringFromDate:[NSDate date]];
            _resourceID = [NSString stringWithFormat:@"%@%@%@%@%d",_resourceID,separator,timeNow,separator,(arc4random() % INT_MAX)];
        }
    }
    return _resourceID;
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
