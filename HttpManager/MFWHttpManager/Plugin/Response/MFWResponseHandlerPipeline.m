//  Created by MFWMobile on 14-1-22.
//  Copyright (c) 2014年 MFWMobile. All rights reserved.
//

#import "MFWResponseHandlerPipeline.h"

@implementation MFWResponseHandlerPipeline

@synthesize queue = _queue;
@synthesize responseHandleBlock = _responseHandleBlock;

+ (MFWResponseHandlerPipeline *)pipeline
{
    return [[self alloc] initWithQueue:nil];
}

+ (MFWResponseHandlerPipeline *)builderPipeline:(NSArray *)builderQueue
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

- (void)setQueue:(NSArray *)queue
{
    _queue = queue;
    __weak MFWResponseHandlerPipeline *weak_self = self;
    self.responseHandleBlock = ^(MFWHttpTask *task) {
        for (id <HttpResponseHandleProtocol> handler in weak_self.queue) {
            if ([handler conformsToProtocol:@protocol(HttpResponseHandleProtocol)]) {
                handler.responseHandleBlock(task);
            }
        }
    };
}
@end
