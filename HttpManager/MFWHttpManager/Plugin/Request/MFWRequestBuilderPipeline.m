//  Created by MFWMobile on 15/8/26.
//  Copyright © 2015年 MFWMobile. All rights reserved.
//

#import "MFWRequestBuilderPipeline.h"

@implementation MFWRequestBuilderPipeline
@synthesize queue = _queue;
@synthesize requestBuildBlock = _requestBuildBlock;

+ (MFWRequestBuilderPipeline *)pipeline
{
    return [[self alloc] initWithQueue:nil];
}

+ (MFWRequestBuilderPipeline *)builderPipeline:(NSArray *)builderQueue
{
    return [[self alloc] initWithQueue:builderQueue];
}

- (void)pipelineBuilderDescription{
}

- (id)copyWithZone:(NSZone *)zone
{
    MFWRequestBuilderPipeline *pipeline = [[[self class] allocWithZone:zone] init];
    NSMutableArray *q = [[NSMutableArray alloc] initWithCapacity:self.queue.count];
    for (MFWRequestBuilderPipeline *builder in self.queue) {
        [q addObject:[builder copy]];
    }
    pipeline.queue = [[NSArray alloc] initWithArray:q];
    return pipeline;
}

- (id)initWithQueue:(NSArray *)queue
{
    self = [super init];
    if (self) {
        _queue = queue;
    }
    return self;
}

- (void)setQueue:(NSArray *)queue
{
    _queue = queue;
    __weak MFWRequestBuilderPipeline *weak_self = self;
    self.requestBuildBlock = ^(MFWHttpTask *task) {
        for (id <HttpRequestBuildProtocol> builder in weak_self.queue) {
            if ([builder conformsToProtocol:@protocol(HttpRequestBuildProtocol)]) {
                builder.requestBuildBlock(task);
            }
        }
    };
}

@end
