//  Created by MFWMobile on 14-1-22.
//  Copyright (c) 2014年 MFWMobile. All rights reserved.
//

#import "MFWResponseHandlerPipeline.h"
#import "MFWHttpManager.h"

@interface MFWResponseHandlerPipelineRunUnit : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, retain) MFWHttpDataTask *task;

@end

@implementation MFWResponseHandlerPipelineRunUnit

@end

@implementation MFWResponseHandlerPipeline

@synthesize queue = _queue;
@synthesize responseHandleBlock = _responseHandleBlock;
@synthesize pipelineHandleCompletionBlock = _pipelineHandleCompletionBlock;

+ (MFWResponseHandlerPipeline *)pipeline
{
    return [[self alloc] initWithQueue:nil];
}

+ (MFWResponseHandlerPipeline *)handlerPipeline:(NSArray *)builderQueue
{
    return [[self alloc] initWithQueue:builderQueue];
}

- (id)copyWithZone:(NSZone *)zone
{
    MFWResponseHandlerPipeline *pipeline = [[[self class] allocWithZone:zone] init];
    NSMutableArray *q = [[NSMutableArray alloc] initWithCapacity:self.queue.count];
    for (MFWResponseHandlerPipeline *handler in self.queue) {
        [q addObject:[handler copy]];
    }
    pipeline.queue = [[NSArray alloc] initWithArray:q];
    return pipeline;
}

- (id)initWithQueue:(NSArray *)queue
{
    self = [super init];
    if (self) {
        self.queue = queue;
    }
    return self;
}

- (void)setQueue:(NSArray<MFWResponseBaseHandler *> *)queue
{
    _queue = queue;

    for (MFWResponseBaseHandler *hander in queue) {
        MFWHttpManagerAssert(![hander isKindOfClass:[MFWResponseHandlerPipeline class]], @"不能在一个queue里面添加一个queue");
    }
    
    __weak MFWResponseHandlerPipeline *weak_self = self;
    self.responseHandleBlock = ^(MFWHttpDataTask *task) {
        MFWResponseHandlerPipelineRunUnit *unit = [[MFWResponseHandlerPipelineRunUnit alloc] init];
        unit.task = task;
        [weak_self _runHandler:unit];
    };
}


- (void)_runHandler:(MFWResponseHandlerPipelineRunUnit *)unit
{
    if (unit.index < self.queue.count) {
        MFWResponseBaseHandler *handler = self.queue[unit.index];
        
        void(^nextBlock)() = ^(){
            unit.index += 1;
            [self _runHandler:unit];
        };
        
        void(^handlerThenCallNextBlock)() = ^(){
            @autoreleasepool {
                handler.responseHandleBlock(unit.task);
            }
            nextBlock();
        };
        
        /**
         这里不能使用GCD或NSOperation，执行关于UIKit的后台操作，否则会影响Camera的运行，导致黑屏，
         详见 https://github.com/idamediafoundry/CameraTest
         等稍后研究下有没有hack的解决方案，这可能是iOS7的摄像头bug，
         临时解决方法参考：http://stackoverflow.com/questions/18930436/ios-7-uiimagepickercontroller-camera-no-image
         将后台调用方式，改为NSThread的detachNewThreadSelector
         */
        if (handler.runningInBackground && [NSThread isMainThread]) {
            [NSThread detachNewThreadSelector:@selector(_handlerThenCallNextBlockInNewThread:)
                                     toTarget:self withObject:handlerThenCallNextBlock];
        } else if (handler.runningInBackground == NO && [NSThread isMainThread] == NO) {
            dispatch_async(dispatch_get_main_queue(), handlerThenCallNextBlock);
        } else {
            handlerThenCallNextBlock();
        }
    }
    else {
        if ([NSThread isMainThread]) {
            [self _finishHandle:unit];
        } else {
            [self performSelectorOnMainThread:@selector(_finishHandle:) withObject:unit waitUntilDone:NO];
        }
    }
}

- (void)_finishHandle:(MFWResponseHandlerPipelineRunUnit *)unit
{
    self.pipelineHandleCompletionBlock(unit.task);
}

- (void)_handlerThenCallNextBlockInNewThread:(dispatch_block_t)nextBlock
{
    if (nextBlock) {
        nextBlock();
    }
}

@end
