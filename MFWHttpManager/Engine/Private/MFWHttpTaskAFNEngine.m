//
//  MFWHttpTaskAFNEngine.m
//  HttpManager
//
//  Created by MFWMobile on 15/10/13.
//  Copyright © 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpTaskAFNEngine.h"
#import "AFNetworking.h"
#import "MFWRequest.h"
#import "MFWResponse.h"
#import "MFWRequestBuilderPipeline.h"
#import "MFWResponseHandlerPipeline.h"
#import  <objc/runtime.h>
#import <libkern/OSAtomic.h>

#define LOCK(...) OSSpinLockLock(&_lock); \
__VA_ARGS__; \
OSSpinLockUnlock(&_lock);


typedef enum{
    MapTaskStatusNone  =     0,
    MapTaskStatusAdded =     1,
    MapTaskStatusStarted =   2,
    MapTaskStatusSucceeded = 3,
    MapTaskStatusFailed =    4,
    MapTaskStatusCanceled =  5
}MapTaskStatus;

typedef NS_ENUM(NSUInteger, MapTaskType)
{
    MapTaskTypeRequest = 0,
    MapTaskTypeDownload ,
    MapTaskTypeUpload
};

const char *MFWHttpTaskResponseKEY = "_response";
@interface MFWHttpDataTask(MFWHttpTaskAFNEngine)
//获取对应的资源ID
@property (nonatomic, assign) HttpTaskStatus taskStatus;                     //task 状态
@end


@implementation MFWHttpDataTask(MFWHttpTaskAFNEngine)

@dynamic taskStatus;

- (void)setResponse:(MFWResponse *)response
{
    objc_setAssociatedObject(self, &MFWHttpTaskResponseKEY, response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (MFWResponse *)response
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
@property(nonatomic,strong) NSMutableArray<MFWHttpDataTask *> *tasks;
@property(nonatomic,assign) MapTaskStatus mapTaskStatus;
@property(nonatomic,  copy) NSString *url;
@property(nonatomic,strong) NSDictionary *parameters;
@property(nonatomic,strong) NSDictionary<NSString*,NSString*> *requestHeaders;
@property(nonatomic,  copy) NSString *httpMethodString;
@property(nonatomic,strong) id responseObj;
@property(nonatomic,strong) NSError *error;
@property(nonatomic,assign) MapTaskType type;
@property(nonatomic,  copy) id <HttpRequestBuildProtocol> requestPlugin;//公有前插件
@property(nonatomic,  copy) id <HttpResponseHandleProtocol> responsePlugin;//公有后插件
@property(nonatomic,assign) NSTimeInterval timeOut;
@property(nonatomic,strong) NSProgress *progress; // 上传下载用
@property(nonatomic,strong) NSURL *downLoadFilePath; //下载下来的文件地址;
@property(nonatomic,strong) NSDictionary<NSString *, NSURL *> *uploadData; //only uploadTaskType use


- (void)addHttpTask:(MFWHttpDataTask *)httpTask;

- (void)cancelHttpTask:(MFWHttpDataTask *)httpTask;

- (BOOL)isRunning;

- (BOOL)isCancelled;

@end

@implementation __MFWAFNMapTask

- (instancetype)init
{
    self = [super init];
    if(self){
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (void)addHttpTask:(MFWHttpDataTask *)httpTask
{
    if(httpTask != nil && ![self.tasks containsObject:httpTask]){
        [self _runRequestPluginFormTask:httpTask];
        [self.tasks addObject:httpTask];
        httpTask.taskStatus = self.sessionTask != nil ? HttpTaskStatusStarted:HttpTaskStatusAdded;
    }
}


- (void)cancelHttpTask:(MFWHttpDataTask *)httpTask
{
    if (httpTask == nil)
    {
        return;
    }
    
    if([self.tasks containsObject:httpTask])
    {
        httpTask.taskStatus = HttpTaskStatusCanceled;
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
- (void)_runRequestPluginFormTask:(MFWHttpDataTask *)httpTask
{
    if(self.requestPlugin != nil &&
       self.requestPlugin.requestBuildBlock !=nil)
    {
        self.requestPlugin.requestBuildBlock(httpTask);
    }
}
#pragma mark - 执行后插件
- (void)_runResponsePluginFormTask:(MFWHttpDataTask *)httpTask
{
    if(self.responsePlugin != nil &&
       self.responsePlugin.responseHandleBlock !=nil)
    {
        self.responsePlugin.responseHandleBlock(httpTask);
    }
    
    if(httpTask.responsePlugin != nil && httpTask.responsePlugin.responseHandleBlock != nil)
    {
        httpTask.responsePlugin.responseHandleBlock(httpTask);
    }
//    httpTask.responsePlugin = nil;
}


#pragma mark - 请求完成的回调
- (void)_complection
{
    MFWResponse *response = [[MFWResponse alloc] initWithUrlResponse:self.sessionTask.response reponseObj:self.responseObj];

    [self.tasks enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop) {
        aTask.response = response;
        [self _runResponsePluginFormTask:aTask];
        if(aTask.compBlock != nil){
            aTask.compBlock(self.error == nil?YES:NO, self.error.code==NSURLErrorCancelled?YES:NO,self.responseObj,self.error);
        }
        aTask.taskStatus = (int)self.mapTaskStatus;
        //为保证在遍历时保证数组元素个数正确同步，开启一个新的runloop 去做这件事情
        [self.tasks performSelector:@selector(removeObject:) withObject:aTask afterDelay:0.0f];
    }];
    [self _destroy];
}


#pragma -mark 取消请求
- (void)_cancel
{
    [self.tasks enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if(aTask.taskStatus != HttpTaskStatusCanceled){
            aTask.taskStatus = HttpTaskStatusCanceled;
        }
    }];
    [self _destroy];
}


#pragma mark 销毁
- (void)_destroy
{
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
            [self.tasks enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull httpTask, NSUInteger idx, BOOL * _Nonnull stop) {
                if(httpTask.taskStatus != HttpTaskStatusAdded){
                    httpTask.taskStatus = HttpTaskStatusAdded;
                }
            }];
        }
        break;
        
        case MapTaskStatusStarted:
        {
            [self.tasks enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull httpTask, NSUInteger idx, BOOL * _Nonnull stop) {
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

#pragma mark override downLoadFilePath
- (void)setDownLoadFilePath:(NSURL *)downLoadFilePath
{
    _downLoadFilePath = downLoadFilePath;
    if(downLoadFilePath != nil && self.type == MapTaskTypeDownload){
        NSString *fileName = [self.sessionTask.response suggestedFilename];
        [self.tasks enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop) {
            if([aTask.saveDownloadFileName length]<1 && [fileName length]>0){
                aTask.saveDownloadFileName = fileName;
            }
            if([aTask.saveDownloadFileName length]>0 && [aTask.saveDownloadFilePath length]>0){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error = nil;
                NSURL *targetURL= [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",aTask.saveDownloadFilePath,aTask.saveDownloadFileName]];
                if(![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",aTask.saveDownloadFilePath,aTask.saveDownloadFileName]]){
                    [fileManager copyItemAtURL:downLoadFilePath  toURL:targetURL error:&error];
                }
            }
        }];
    }
}


- (void)setProgress:(NSProgress *)progress
{
    _progress = progress;
    [self.tasks enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull httpTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if(httpTask.progerssBlock != nil){
           httpTask.progerssBlock(httpTask,progress);
        }
    }];
}

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define  BACKGROUND_SESSION_IDENTIFIER @"com.mafengwo.mobile.backgroundSession"
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
@synthesize HTTPMaximumConnectionsPerHost = _HTTPMaximumConnectionsPerHost; //Default 4 setting by AFN
@synthesize maxConcurrentOperationCount = _maxConcurrentOperationCount; //Default 1 setting by AFN


- (instancetype)init
{
    self = [super init];
    if(self){
        _sessionManager = [AFHTTPSessionManager manager];
        if([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]){
            _backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:BACKGROUND_SESSION_IDENTIFIER]];
        }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            _backgroundSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:BACKGROUND_SESSION_IDENTIFIER]];
#pragma clang diagnostic pop
        }
        _backgroundSessionManager.session.configuration.HTTPMaximumConnectionsPerHost = self.HTTPMaximumConnectionsPerHost;
        [self _createTempDownloadTableDirectory];
        _tempDownloadTable = [self _readTempDownloadTablePlist];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_synchronizedTempDownloadTable) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_filterRemoveMapTask:) name:MFWMAPTASK_DESTROY_NOTIFICATION object:nil];
        _repeatRequestFilter = [[NSMutableDictionary alloc] init];
        _lock = OS_SPINLOCK_INIT;
        _taskList = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark 获取MapTask
- (__MFWAFNMapTask*)_getMapTaskByHttpTask:(MFWHttpDataTask *)httpTask
{
    if([httpTask.identifier length]<1){
        NSAssert(NO, @"httpTask resourceID can't be a  nil");
        return nil;
    }else{
        if([self.repeatRequestFilter objectForKey:httpTask.identifier] != nil && [[self.repeatRequestFilter objectForKey:httpTask.identifier] isMemberOfClass:[__MFWAFNMapTask class]]){
            __MFWAFNMapTask *mapTask = [self.repeatRequestFilter objectForKey:httpTask.identifier];
            if(![mapTask.tasks containsObject:httpTask]){
                [mapTask addHttpTask:httpTask];
                [self.taskList addPointer:(__bridge void*)httpTask];
            }
            return mapTask;
        }else{
            __MFWAFNMapTask *mapTask = [[__MFWAFNMapTask alloc] init];
            mapTask.identifier = httpTask.identifier;
            mapTask.url = httpTask.request.URLString;
            mapTask.parameters = httpTask.request.params;
            mapTask.requestHeaders = httpTask.request.header.httpRequestHeaderFields;
            mapTask.httpMethodString = httpTask.request.httpMethodString;
            mapTask.type = (int)httpTask.taskType;
            mapTask.requestPlugin = self.requestPlugin;
            mapTask.responsePlugin = self.responsePlugin;
            mapTask.timeOut = httpTask.request.requestTimeout;
            [mapTask addHttpTask:httpTask];
            [self.taskList addPointer:(__bridge void*)httpTask];
            if(httpTask.taskType == HttpTaskTypeUpload){
                mapTask.uploadData = httpTask.uploadData;
            }
            [self.repeatRequestFilter setObject:mapTask forKey:httpTask.identifier];
            return mapTask;
        }
    }
}

#pragma mark - 入口
- (void)executeTask:(MFWHttpDataTask *)httpTask complection:(MFWHttpTaskCompletion)completion
{
    if (httpTask == nil || [httpTask.request.URLString length] ==0)
    {
        return;
    }
    if(completion != nil)
    {
        httpTask.compBlock = completion;
    }
    
    if(httpTask.requestPlugin != nil &&
       httpTask.requestPlugin.requestBuildBlock !=nil)
    {
        httpTask.requestPlugin.requestBuildBlock(httpTask);
    }
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
        mapTask.mapTaskStatus = MapTaskStatusAdded;
        NSURLSessionDataTask *dataTask = nil;
        NSError *error = nil;
        NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:mapTask.httpMethodString URLString:mapTask.url parameters:mapTask.parameters error:&error];
        request.timeoutInterval = mapTask.timeOut;
        [[mapTask.requestHeaders allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = [mapTask.requestHeaders valueForKey:key];
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
            downloadSessionTask =  [self.backgroundSessionManager downloadTaskWithResumeData:data progress:^(NSProgress *progress){
                mapTask.progress = progress;
            } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                //只有下载成功才会走这里
                mapTask.downLoadFilePath = targetPath;
                return targetPath;
            } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                MFWHttpTaskAFNEngine *sself = wself;
                mapTask.error = error;
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
                NSString *value = [mapTask.requestHeaders valueForKey:key];
                [request addValue:value forHTTPHeaderField:key];
            }];
            if(error == nil){
                downloadSessionTask =  [self.backgroundSessionManager downloadTaskWithRequest:request progress:^(NSProgress *progress){
                    mapTask.progress = progress;
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    //只有下载成功才会走这里
                    mapTask.downLoadFilePath = targetPath;
                    return targetPath;
                } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                    MFWHttpTaskAFNEngine *sself = wself;
                    mapTask.error = error;
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
    }
}

//清理下载记录
- (void)_clearDownloadLogByResourceId:(NSString *)resourceID
{
    if([resourceID length]>0){
        LOCK([self.tempDownloadTable removeObjectForKey:resourceID]);
        [self _synchronizedTempDownloadTable];
        [self _removeTempDownloadFileByFileName:resourceID];
    }
}

//创建临时下载表文件夹
- (void)_createTempDownloadTableDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),TEMP_DOWNLOAD_TABLE_PATH];
    if(![fileManager fileExistsAtPath:path]){
        NSError *error =nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
}


//把临时下载表读进内存
- (NSMutableDictionary *)_readTempDownloadTablePlist
{
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *path = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),TEMP_DOWNLOAD_TABLE_PATH,TEMP_DOWNLOAD_TABLE_FILE_NAME];
    if([fileManager fileExistsAtPath:path]){
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        //检查一下下载缓存表的数据时间，如果大于一周就丢弃下载缓存记录数据
        if([plist count]>0){
            for(NSString *resourceId in [plist allKeys]){
                NSString *timeStr = [plist objectForKey:resourceId];
                if([timeStr length]>0){
                    NSTimeInterval createTime = [timeStr floatValue];
                    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
                    if((nowTime - createTime)> 3600*24*7){
                        [plist removeObjectForKey:resourceId];
                        [self _removeTempDownloadFileByFileName:resourceId];
                    }
                }
            }
        }
        return plist;
    }else{
        return [NSMutableDictionary dictionary];
    }
}

//把内存中的临时下载表持久化
-(void)_synchronizedTempDownloadTable
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
        [self _synchronizedTempDownloadTable];
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
        NSMutableURLRequest *request =  [self.backgroundSessionManager.requestSerializer multipartFormRequestWithMethod:mapTask.httpMethodString URLString:mapTask.url parameters:mapTask.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [[mapTask.uploadData allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                NSURL *url = [mapTask.uploadData objectForKey:key];
                [formData appendPartWithFileURL:url name:key error:nil];
            }];
        } error:&error];
        request.timeoutInterval = mapTask.timeOut;
        [[mapTask.requestHeaders allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = [mapTask.requestHeaders valueForKey:key];
            [request addValue:value forHTTPHeaderField:key];
        }];
        if(error == nil){
            mapTask.mapTaskStatus = MapTaskStatusAdded;
            NSURLSessionUploadTask *uploadDataTask = nil;
            uploadDataTask = [self.sessionManager uploadTaskWithStreamedRequest:request  progress:^(NSProgress *aProgress){
                mapTask.progress = aProgress;
            }completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error){
                mapTask.responseObj = responseObject;
                mapTask.error = error;
                mapTask.mapTaskStatus =  error == nil ? MapTaskStatusSucceeded : MapTaskStatusFailed;
            }];
            uploadDataTask.mFWHttpTaskAFNEngine_resourceID = mapTask.identifier;
            mapTask.sessionTask = uploadDataTask;
            [uploadDataTask resume];
            mapTask.mapTaskStatus = MapTaskStatusStarted;
        }else{
            NSAssert(NO, @"创建上传请求失败");
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
- (void)cancelTask:(MFWHttpDataTask *)httpTask
{
    if(httpTask == nil || ![[self.taskList allObjects] containsObject:httpTask]){
        return;
    }
    LOCK(__MFWAFNMapTask *mapTask = [self _getMapTaskByHttpTask:httpTask];
         [mapTask cancelHttpTask:httpTask]);
    if([mapTask isCancelled]){
        NSURLSessionTask *sessionTask = mapTask.sessionTask;
        __weak MFWHttpTaskAFNEngine *wself = self;
        if(sessionTask != nil)
        {
            if([sessionTask isKindOfClass:[NSURLSessionDownloadTask class]])
            {
                NSURLSessionDownloadTask *sessionDownloadTask = (NSURLSessionDownloadTask *)sessionTask;
                [sessionDownloadTask cancelByProducingResumeData:^(NSData *resumeData)
                 {
                     MFWHttpTaskAFNEngine *sself = wself;
                     [sself _saveTempDownloadFileBy:resumeData fileName:sessionTask.mFWHttpTaskAFNEngine_resourceID];
                 }];
            }
            else{
                [sessionTask cancel];
            }
        }
        mapTask.mapTaskStatus = MapTaskStatusCanceled;
    }
}

- (void)cancelAllTask
{
    [[self.taskList allObjects] enumerateObjectsUsingBlock:^(MFWHttpDataTask * _Nonnull aTask, NSUInteger idx, BOOL * _Nonnull stop) {
        if(aTask.taskStatus == HttpTaskStatusAdded || aTask.taskStatus == HttpTaskStatusStarted){
            [self cancelTask:aTask];
        }
    }];
}

#pragma mark override getter httpTasks
- (NSArray *)httpTasks
{
    return [self.taskList allObjects];
}

#pragma mark override setter HTTPMaximumConnectionsPerHost
- (void)setHTTPMaximumConnectionsPerHost:(NSUInteger)HTTPMaximumConnectionsPerHost
{
    if(HTTPMaximumConnectionsPerHost < 1){
        return;
    }
    _HTTPMaximumConnectionsPerHost = HTTPMaximumConnectionsPerHost;
    
    if(self.sessionManager.session.configuration != nil){
        self.sessionManager.session.configuration.HTTPMaximumConnectionsPerHost =HTTPMaximumConnectionsPerHost;
    }
    
    if(self.backgroundSessionManager.session.configuration.HTTPMaximumConnectionsPerHost){
        self.backgroundSessionManager.session.configuration.HTTPMaximumConnectionsPerHost =HTTPMaximumConnectionsPerHost;
    }
}

#pragma mark override setter maxConcurrentOperationCount

-(void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount
{
    if(maxConcurrentOperationCount <1){
        return;
    }
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    if(self.sessionManager.operationQueue != nil){
        self.sessionManager.operationQueue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
    }
    if(self.backgroundSessionManager.operationQueue != nil){
        self.backgroundSessionManager.operationQueue.maxConcurrentOperationCount = _maxConcurrentOperationCount;
    }
}


@end
