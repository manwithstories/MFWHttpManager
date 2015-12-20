//
//  MFWHttpTaskAFNEngine.m
//  HttpManager
//
//  Created by MFWMobile on 15/10/13.
//  Copyright © 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpTaskAFNEngine.h"
#import "AFNetworking.h"
#import "MFWHttpRequest.h"
#import "MFWHttpResponse.h"
#import "MFWRequestBuilderPipeline.h"
#import "MFWResponseHandlerPipeline.h"
#import  <objc/runtime.h>
#import <libkern/OSAtomic.h>


#define LOCK(...) OSSpinLockLock(&_lock); \
__VA_ARGS__; \
OSSpinLockUnlock(&_lock);


typedef enum{
    MapTaskStatusAdded =     0,
    MapTaskStatusStarted =   1,
    MapTaskStatusSucceeded = 2,
    MapTaskStatusFailed =    3,
    MapTaskStatusCanceled =  4
}MapTaskStatus;


const char *MFWHttpTaskResponseKEY = "_response";
@implementation MFWHttpTask(MFWHttpTaskAFNEngine)
- (void)setResponse:(MFWHttpResponse *)response
{
    objc_setAssociatedObject(self, &MFWHttpTaskResponseKEY, response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (MFWHttpResponse *)response
{
    return objc_getAssociatedObject(self, &MFWHttpTaskResponseKEY);
}
@end


#define MFWMAPTASK_DESTROY_NOTIFICATION @"MFWMAPTASK_DESTROY_NOTIFICATION"

const char *NSURLSessionDownloadTaskResourceIDKEY = "NSURLSessionDownloadTaskResourceIDKEY";
@interface NSObject(MFWHttpTaskAFNEngine)
@property(nonatomic,strong)NSString * mFWHttpTaskAFNEngine_resourceID;
@end

@implementation NSObject(MFWHttpTaskAFNEngine)

- (void)setMFWHttpTaskAFNEngine_resourceID:(NSString *)mFWHttpTaskAFNEngine_resourceID
{
     objc_setAssociatedObject(self, &NSURLSessionDownloadTaskResourceIDKEY, mFWHttpTaskAFNEngine_resourceID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)mFWHttpTaskAFNEngine_resourceID
{
     return  objc_getAssociatedObject(self, &NSURLSessionDownloadTaskResourceIDKEY);
}
@end


/////////////////////////////////////////////////////////////////////////////////////////////////////
@interface __MFWAFNMapTask : NSObject

@property(nonatomic,  copy) NSString *identifier;
@property(nonatomic,strong) NSURLSessionTask *sessionTask;
@property(nonatomic,strong) NSMutableArray<MFWHttpTask *> *tasks;
@property(nonatomic,assign) MapTaskStatus mapTaskStatus;
@property(nonatomic,  copy) NSString *url;
@property(nonatomic,strong) NSDictionary *parameters;
@property(nonatomic,strong) NSDictionary *requestHeaders;
@property(nonatomic,  copy) NSString *httpMethodString;
@property(nonatomic,strong) id responseObj;
@property(nonatomic,strong) NSError *error;
@property(nonatomic,assign) HttpTaskType type;
@property(nonatomic,  copy) id <HttpRequestBuildProtocol> requestPlugin;//公有前插件
@property(nonatomic,  copy) id <HttpResponseHandleProtocol> responsePlugin;//公有后插件
@property(nonatomic,assign) NSTimeInterval timeOut;
@property(nonatomic,strong) NSProgress *progress; // 上传下载用
@property(nonatomic,strong) NSURL *downLoadFilePath; //下载下来的文件地址;
@property(nonatomic,strong) NSDictionary<NSString *, NSURL *> *uploadData; //only uploadTaskType use


- (void)addHttpTask:(MFWHttpTask *)httpTask;

- (void)cancelHttpTask:(MFWHttpTask *)httpTask;

- (BOOL)isRunning;

- (BOOL)isCancelled;

@end

@implementation __MFWAFNMapTask

- (void)dealloc
{
    NSLog(@"%@ 释放了",self);
    [_progress removeObserver:self forKeyPath:@"completedUnitCount"];
}

- (instancetype)init
{
    self = [super init];
    if(self){
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (void)addHttpTask:(MFWHttpTask *)httpTask
{
    if(httpTask != nil && ![self.tasks containsObject:httpTask]){
        [self _runRequestPluginFormTask:httpTask];
        [self.tasks addObject:httpTask];
        httpTask.taskStatus = self.sessionTask != nil ? HttpTaskStatusStarted:HttpTaskStatusAdded;
    }
}

- (void)cancelHttpTask:(MFWHttpTask *)httpTask
{
    httpTask.taskStatus = HttpTaskStatusCanceled;
    if(httpTask != nil && [self.tasks containsObject:httpTask]){
        [self.tasks removeObject:httpTask];
    }
}

- (BOOL)isRunning
{
    return self.sessionTask != nil ? YES:NO;
}

- (BOOL)isCancelled
{
    return [self.tasks count] == 0 ? YES:NO;
}

#pragma mark - 执行前插件
- (void)_runRequestPluginFormTask:(MFWHttpTask *)httpTask
{
    if(self.requestPlugin != nil){
        self.requestPlugin.requestBuildBlock(httpTask);
    }
}
#pragma mark - 执行后插件
- (void)_runResponsePluginFormTask:(MFWHttpTask *)httpTask
{
    if(self.responsePlugin != nil){
        self.responsePlugin.responseHandleBlock(httpTask);
    }
    if(httpTask.responsePlugin != nil){
        httpTask.responsePlugin.responseHandleBlock(httpTask);
    }
    httpTask.responsePlugin = nil;
}

#pragma mark - 请求完成的回调
- (void)_complection
{
    MFWHttpResponse *response = [[MFWHttpResponse alloc] initWithUrlResponse:self.sessionTask.response reponseObj:self.responseObj];
    
    [self.tasks enumerateObjectsUsingBlock:^(MFWHttpTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop) {
        aTask.response = response;
        [self _runResponsePluginFormTask:aTask];
        if(aTask.compBlock != nil){
            aTask.compBlock(self.error == nil?YES:NO, self.error.code==NSURLErrorCancelled?YES:NO,self.responseObj,self.error);
        }
        aTask.taskStatus = (int)self.mapTaskStatus;
        switch (aTask.taskType) {
            case HttpTaskTypeDownload:
            {
                if(aTask.taskStatus == HttpTaskStatusSucceeded && aTask.cacheHandler != nil && [aTask.cacheHandler respondsToSelector:@selector(saveDownloadFile:dataId:)]){
                    [aTask.cacheHandler saveDownloadFile:self.downLoadFilePath dataId:aTask.resourceID];
                }
            }
                break;
                
            default:
            {
                if(aTask.taskStatus == HttpTaskStatusSucceeded  &&  aTask.cacheHandler != nil && [aTask.cacheHandler respondsToSelector:@selector(saveCacheData:dataId:)]){
                    [aTask.cacheHandler saveCacheData:self.responseObj dataId:aTask.resourceID];
                }
            }
                break;
        }

    }];
    [self _destroy];
}


#pragma -mark 取消请求
- (void)_cancel
{
    [self.tasks enumerateObjectsUsingBlock:^(MFWHttpTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if(aTask.taskStatus != HttpTaskStatusCanceled){
            aTask.taskStatus = HttpTaskStatusCanceled;
        }
    }];
    [self _destroy];
}


#pragma mark 销毁
- (void)_destroy
{
    self.sessionTask = nil;
    [self.tasks removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:MFWMAPTASK_DESTROY_NOTIFICATION object:nil userInfo:@{@"identifier":self.identifier}];
}


#pragma mark - override setter
- (void)setMapTaskStatus:(MapTaskStatus)mapTaskStatus
{
    _mapTaskStatus  = mapTaskStatus;
    switch (_mapTaskStatus) {
        case MapTaskStatusAdded:
        {
            [self.tasks enumerateObjectsUsingBlock:^(MFWHttpTask * _Nonnull httpTask, NSUInteger idx, BOOL * _Nonnull stop) {
                if(httpTask.taskStatus != HttpTaskStatusAdded){
                    httpTask.taskStatus = HttpTaskStatusAdded;
                }
            }];
        }
        break;
        
        case MapTaskStatusStarted:
        {
            [self.tasks enumerateObjectsUsingBlock:^(MFWHttpTask * _Nonnull httpTask, NSUInteger idx, BOOL * _Nonnull stop) {
                if(httpTask.taskStatus != HttpTaskStatusStarted){
                    httpTask.taskStatus = HttpTaskStatusStarted;
                }
            }];
        }
        break;
            
        case MapTaskStatusCanceled:
        {
            [self _cancel];
        }
        break;
            
        default://success or failure
        {
            [self _complection];
        }
        break;
    }
}


#pragma mark kvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"completedUnitCount"]){
        [self.tasks enumerateObjectsUsingBlock:^(MFWHttpTask * _Nonnull httpTask, NSUInteger idx, BOOL * _Nonnull stop) {
            if(httpTask.progerssBlock != nil){
               httpTask.progerssBlock(httpTask,self.progress);
            }
        }];
    }
}

- (void)setProgress:(NSProgress *)progress
{
    _progress = progress;
    [_progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define  TEMP_DOWNLOAD_TABLE_PATH @"/Documents/.TempDownloadTable"
#define  TEMP_DOWNLOAD_TABLE_FILE_NAME @"download.plist"
#define  TEMP_DOWNLOAD_FILE_PATH @"/Library/Caches/.TempDownload"
#define  KEY_TEMP_PATH   @"temp_path"
#define  KEY_CREATE_TIME @"create_time"

@interface MFWHttpTaskAFNEngine()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic,strong) AFHTTPSessionManager *backgroundSessionManager;
@property (nonatomic,strong) NSMutableDictionary  *tempDownloadTable; //临时下载表内存缓存
@property (nonatomic,strong) NSMutableDictionary<NSString *,__MFWAFNMapTask*> *repeatRequestFilter; //重复请求过滤器,当请求同一资源的MFWHttpTask已经在队列中存在了,那么就不再重复的发起请求,只同步该Task的状态。
@property (nonatomic,strong) NSPointerArray *taskList;
@end

@implementation MFWHttpTaskAFNEngine
{
    OSSpinLock _lock;
}

+ (instancetype)defaultEngine
{
    return [[self alloc] initWithSingleIdentifier:@"com.mafengwo.defaultAFNEngine"];
}

- (instancetype)initWithSingleIdentifier:(NSString *)identifier
{
    return [super initWithSingleIdentifier:identifier];
}

- (instancetype)init
{
    self = [super init];
    if(self){
        _sessionManager = [AFHTTPSessionManager manager];
        if([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]){
            _backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.mafengwo.mobile"]];
        }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            _backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:@"com.mafengwo.mobile"]];
#pragma clang diagnostic pop
        }
        [self _createTempDownloadTableDirectory];
        _tempDownloadTable = [self _readTempDownloadTablePlist];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_synchronTempDownloadTable) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_filterRemoveMapTask:) name:MFWMAPTASK_DESTROY_NOTIFICATION object:nil];
        _repeatRequestFilter = [[NSMutableDictionary alloc] init];
        _lock = OS_SPINLOCK_INIT;
        _taskList = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark 获取MapTask
- (__MFWAFNMapTask*)_getMapTaskByHttpTask:(MFWHttpTask *)httpTask
{
    if([httpTask.resourceID length]<1){
        NSAssert(NO, @"httpTask resourceID can't be a  nil");
        return nil;
    }else{
        if([self.repeatRequestFilter objectForKey:httpTask.resourceID] != nil && [[self.repeatRequestFilter objectForKey:httpTask.resourceID] isMemberOfClass:[__MFWAFNMapTask class]]){
            __MFWAFNMapTask *mapTask = [self.repeatRequestFilter objectForKey:httpTask.resourceID];
            if(![mapTask.tasks containsObject:httpTask]){
                [mapTask addHttpTask:httpTask];
                [self.taskList addPointer:(__bridge void*)httpTask];
            }
            return mapTask;
        }else{
            __MFWAFNMapTask *mapTask = [[__MFWAFNMapTask alloc] init];
            mapTask.identifier = httpTask.resourceID;
            mapTask.url = httpTask.request.URLString;
            mapTask.parameters = httpTask.request.params;
            mapTask.requestHeaders = httpTask.request.header.httpRequestHeaderFields;
            mapTask.httpMethodString = httpTask.request.httpMethodString;
            mapTask.type = httpTask.taskType;
            mapTask.requestPlugin = self.requestPlugin;
            mapTask.responsePlugin = self.responsePlugin;
            mapTask.timeOut = httpTask.request.reqeustTimeout;
            [mapTask addHttpTask:httpTask];
            [self.taskList addPointer:(__bridge void*)httpTask];
            if(httpTask.taskType == HttpTaskTypeUpload){
                mapTask.uploadData = httpTask.uploadData;
            }
            [self.repeatRequestFilter setObject:mapTask forKey:httpTask.resourceID];
            return mapTask;
        }
    }
}

#pragma mark - 入口
- (void)executeTask:(MFWHttpTask *)httpTask complection:(MFWHttpTaskCompletion)completion
{
    if(completion != nil){
        httpTask.compBlock = completion;
    }
    if(httpTask.requestPlugin != nil){
        httpTask.requestPlugin.requestBuildBlock(httpTask);
    }
    
    self.sessionManager.requestSerializer.timeoutInterval = httpTask.request.reqeustTimeout;
   LOCK(__MFWAFNMapTask *mapTask = [self _getMapTaskByHttpTask:httpTask]);
    switch (httpTask.taskType) {
        case HttpTaskTypeRequest:
        {
           [self _requestMapTask:mapTask];
        }
            break;
        case HttpTaskTypeDownload:
        {
           [self _downloadMapTask:mapTask];
        }
            break;
        case HttpTaskTypeUpload:
        {
            [self _uploadMapTask:mapTask];
        }
            break;
        default:
        {
            NSAssert(NO, @"taskType is unkonw");
        }
            break;
    }
}

#pragma mark 普通请求
- (void)_requestMapTask:(__MFWAFNMapTask *)mapTask
{
    if(![mapTask isRunning]){
        mapTask.mapTaskStatus = HttpTaskStatusAdded;
        NSURLSessionDataTask *dataTask = nil;
        NSError *error = nil;
        NSMutableURLRequest *request = [self.backgroundSessionManager.requestSerializer requestWithMethod:mapTask.httpMethodString URLString:mapTask.url parameters:mapTask.parameters error:&error];
        request.timeoutInterval = mapTask.timeOut;
        [[mapTask.requestHeaders allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [mapTask.requestHeaders valueForKey:key];
            [request addValue:value forHTTPHeaderField:key];
        }];
        if(error == nil){
            dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
                mapTask.responseObj = responseObject;
                mapTask.error = error;
                mapTask.mapTaskStatus =  error == nil ? MapTaskStatusSucceeded : MapTaskStatusFailed;
            }];
            dataTask.mFWHttpTaskAFNEngine_resourceID = mapTask.identifier;
            mapTask.sessionTask = dataTask;
            [dataTask resume];
            mapTask.mapTaskStatus = MapTaskStatusStarted;

        }else{
            NSAssert(NO, @"创建普通请求失败");
        }
    }
}


#pragma mark 下载请求
- (void)_downloadMapTask:(__MFWAFNMapTask *)mapTask
{
    if(![mapTask isRunning]){
        NSString *resourceID = mapTask.identifier;
        NSString *path = [NSString stringWithFormat:@"%@%@/%@.temp",NSHomeDirectory(),TEMP_DOWNLOAD_FILE_PATH,resourceID];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSURLSessionDownloadTask *downloadSessionTask = nil;
        mapTask.mapTaskStatus = MapTaskStatusAdded;
        MFWHttpTaskAFNEngine *wself = self;
        if(data != nil){
            downloadSessionTask =  [self.backgroundSessionManager downloadTaskWithResumeData:data progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return targetPath;
            } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                MFWHttpTaskAFNEngine *sself = wself;
                mapTask.error = error;
                mapTask.downLoadFilePath = filePath;
                mapTask.mapTaskStatus = error == nil?MapTaskStatusSucceeded:MapTaskStatusFailed;
                if(error == nil){
                    [sself _clearDownloadLogByResourceId:mapTask.identifier];
                }
            }];
        }else{
            NSError *error = nil;
            NSMutableURLRequest *request = [self.backgroundSessionManager.requestSerializer requestWithMethod:mapTask.httpMethodString URLString:mapTask.url parameters:mapTask.parameters error:&error];
            request.timeoutInterval = mapTask.timeOut;
            [[mapTask.requestHeaders allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
                id value = [mapTask.requestHeaders valueForKey:key];
                [request addValue:value forHTTPHeaderField:key];
            }];
            if(error == nil){
                downloadSessionTask =  [self.backgroundSessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    return targetPath;
                } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                    MFWHttpTaskAFNEngine *sself = wself;
                    mapTask.error = error;
                    mapTask.downLoadFilePath = filePath;
                    mapTask.mapTaskStatus = error == nil?MapTaskStatusSucceeded:MapTaskStatusFailed;
                    if(error == nil){
                        [sself _clearDownloadLogByResourceId:mapTask.identifier];
                    }
                }];
            }else{
                NSAssert(NO, @"创建下载请求失败");
            }
        }
        downloadSessionTask.mFWHttpTaskAFNEngine_resourceID = mapTask.identifier;
        mapTask.sessionTask = downloadSessionTask;
        [downloadSessionTask resume];
        mapTask.mapTaskStatus = MapTaskStatusStarted;
        //进度回调
        [self.backgroundSessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask * downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            if(mapTask.progress == nil){
                mapTask.progress = [[NSProgress alloc] init];
            }
            mapTask.progress.totalUnitCount = totalBytesExpectedToWrite;
            mapTask.progress.completedUnitCount = totalBytesWritten;
        }];
    }
}

//清理下载记录
- (void)_clearDownloadLogByResourceId:(NSString *)resourceID
{
    if([resourceID length]>0){
        LOCK([self.tempDownloadTable removeObjectForKey:resourceID]);
        [self _synchronTempDownloadTable];
        [self _removeTempDownloadFileByFileName:resourceID];
    }
}

//创建临时下载表文件夹
- (void)_createTempDownloadTableDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),TEMP_DOWNLOAD_TABLE_PATH];
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}


//把临时下载表读进内存
- (NSMutableDictionary *)_readTempDownloadTablePlist
{
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *path = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),TEMP_DOWNLOAD_TABLE_PATH,TEMP_DOWNLOAD_TABLE_FILE_NAME];
    if([fileManager fileExistsAtPath:path]){
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        return plist;
    }else{
        return [NSMutableDictionary dictionary];
    }
}

//把内存中的临时下载表持久化
-(void)_synchronTempDownloadTable
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       NSString *path = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),TEMP_DOWNLOAD_TABLE_PATH,TEMP_DOWNLOAD_TABLE_FILE_NAME];
       [self.tempDownloadTable writeToFile:path atomically:YES];
    });
}

//保存临时下载数据
- (void)_saveTempDownloadFileBy:(NSData *)data fileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),TEMP_DOWNLOAD_FILE_PATH];
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if(data != nil && [fileName length]>0){
        [self.tempDownloadTable setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:fileName];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [data writeToFile:[NSString stringWithFormat:@"%@/%@.temp",path,fileName] atomically:YES];
        });
        [self _synchronTempDownloadTable];
    }
}

//删除临时下载数据
- (void)_removeTempDownloadFileByFileName:(NSString *)fileName
{
    if([fileName length]<1){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@%@/%@.temp",NSHomeDirectory(),TEMP_DOWNLOAD_FILE_PATH,fileName];
        if([fileManager fileExistsAtPath:path]){
            [fileManager removeItemAtPath:path error:nil];
        }
    });
}

#pragma mark 上传请求
- (void)_uploadMapTask:(__MFWAFNMapTask *)mapTask
{
    if(![mapTask isRunning]){
        NSError *error = nil;
        NSMutableURLRequest *request =  [self.sessionManager.requestSerializer multipartFormRequestWithMethod:mapTask.httpMethodString URLString:mapTask.url parameters:mapTask.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [[mapTask.uploadData allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                NSURL *url = [mapTask.uploadData objectForKey:key];
                [formData appendPartWithFileURL:url name:key error:nil];
            }];
        } error:&error];
        request.timeoutInterval = mapTask.timeOut;
        [[mapTask.requestHeaders allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [mapTask.requestHeaders valueForKey:key];
            [request addValue:value forHTTPHeaderField:key];
        }];
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        if(error == nil){
            mapTask.mapTaskStatus = HttpTaskStatusAdded;
            NSURLSessionUploadTask *uploadDataTask = nil;
            NSProgress *aProgress = nil;
            uploadDataTask = [self.sessionManager uploadTaskWithStreamedRequest:request progress:&aProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
                mapTask.responseObj = responseObject;
                mapTask.error = error;
                mapTask.mapTaskStatus =  error == nil ? MapTaskStatusSucceeded : MapTaskStatusFailed;
            }];
            uploadDataTask.mFWHttpTaskAFNEngine_resourceID = mapTask.identifier;
            mapTask.sessionTask = uploadDataTask;
            [uploadDataTask resume];
            mapTask.progress = aProgress;
            mapTask.mapTaskStatus = MapTaskStatusStarted;
        }
    }
}

#pragma mark ExecuteNotification
- (void)_filterRemoveMapTask:(NSNotification *)notfi
{
    NSDictionary *dict = notfi.userInfo;
    if([dict count]>0){
        NSString *identifier = dict[@"identifier"];
        if([identifier length]>0){
            LOCK([self.repeatRequestFilter removeObjectForKey:identifier]);
        }
    }
}

#pragma mark- 取消请求
- (void)cancelTask:(MFWHttpTask *)httpTask
{
   LOCK(__MFWAFNMapTask *mapTask = [self _getMapTaskByHttpTask:httpTask];
        [mapTask cancelHttpTask:httpTask]);
    if([mapTask isCancelled]){
        NSURLSessionTask *sessionTask = mapTask.sessionTask;
        __weak MFWHttpTaskAFNEngine *wself = self;
        if(sessionTask != nil){
            if([sessionTask isKindOfClass:[NSURLSessionDownloadTask class]]){
                NSURLSessionDownloadTask *sessionDownloadTask = (NSURLSessionDownloadTask *)sessionTask;
                [sessionDownloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                    MFWHttpTaskAFNEngine *sself = wself;
                    [sself _saveTempDownloadFileBy:resumeData fileName:sessionTask.mFWHttpTaskAFNEngine_resourceID];
                }];
            }else{
                [sessionTask cancel];
            }
        }
        mapTask.mapTaskStatus = MapTaskStatusCanceled;
    }
}

- (void)cancelAllTask
{
    [self.httpTasks enumerateObjectsUsingBlock:^(MFWHttpTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelTask:obj];
    }];
}


#pragma mark override  getter
- (NSArray *)httpTasks
{
  return [self.taskList allObjects];
}

@end
