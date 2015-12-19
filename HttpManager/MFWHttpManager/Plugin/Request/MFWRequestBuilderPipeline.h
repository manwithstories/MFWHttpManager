//  Created by MFWMobile on 15/8/26.
//  Copyright © 2015年 MFWMobile. All rights reserved.
//

#import "MFWRequestBaseBuilder.h"

@interface MFWRequestBuilderPipeline : MFWRequestBaseBuilder

@property (nonatomic, strong) NSArray *queue;

+ (MFWRequestBuilderPipeline *)pipeline;
+ (MFWRequestBuilderPipeline *)builderPipeline:(NSArray *)pipeline;

//主要用于输出当前流水线的所有builder
- (void)pipelineBuilderDescription;


@end
