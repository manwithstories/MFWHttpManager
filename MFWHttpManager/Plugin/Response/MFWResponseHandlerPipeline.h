//  Created by MFWMobile on 14-1-22.
//  Copyright (c) 2014年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFWHttpDataTask.h"
#import "MFWResponseBaseHandler.h"

@protocol MFWResponsePipelineHandleCompletionBlock <NSObject>

@property (nonatomic, copy) MFWHttpResponseHandleBlock pipelineHandleCompletionBlock;

@end

@interface MFWResponseHandlerPipeline : MFWResponseBaseHandler <MFWResponsePipelineHandleCompletionBlock>

@property (nonatomic, strong) NSArray<MFWResponseBaseHandler *> *queue;

+ (MFWResponseHandlerPipeline *)pipeline;
+ (MFWResponseHandlerPipeline *)handlerPipeline:(NSArray<MFWResponseBaseHandler *> *)pipeline;

@end
