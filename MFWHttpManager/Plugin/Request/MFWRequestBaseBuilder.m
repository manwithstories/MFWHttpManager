//  Created by MFWMobile on 15/8/26.
//  Copyright © 2015年 MFWMobile. All rights reserved.
//

#import "MFWRequestBaseBuilder.h"

@implementation MFWRequestBaseBuilder

@synthesize requestBuildBlock = _requestBuildBlock;

+ (id <HttpRequestBuildProtocol>)builder
{
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone
{
    MFWRequestBaseBuilder *builder = [[[self class] allocWithZone:zone] init];
    /**
     *  不去覆盖初始化时创建的block
     */
    
    if (builder.requestBuildBlock == nil) {
        builder.requestBuildBlock = self.requestBuildBlock;
    }
    return builder;
}

@end
