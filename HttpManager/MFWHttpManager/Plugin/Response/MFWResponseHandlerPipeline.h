//  Created by MFWMobile on 14-1-22.
//  Copyright (c) 2014年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFWHttpTask.h"
#import "MFWResponseBaseHandler.h"

@interface MFWResponseHandlerPipeline : MFWResponseBaseHandler
@property (nonatomic, strong) NSArray *queue;

+ (MFWResponseHandlerPipeline *)pipeline;
+ (MFWResponseHandlerPipeline *)builderPipeline:(NSArray *)pipeline;
@end
