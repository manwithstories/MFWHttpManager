//  Created by MFWMobile on 14-1-22.
//  Copyright (c) 2014年 MFWMobile. All rights reserved.
//

#import "MFWResponseBaseHandler.h"

@implementation MFWResponseBaseHandler
@synthesize responseHandleBlock = _responseHandleBlock;
@synthesize inBackgroundRun = _inBackgroundRun;
+ (id<HttpResponseHandleProtocol>)handler
{
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone
{
    MFWResponseBaseHandler *handler = [[[self class] allocWithZone:zone] init];
    /**
     *  不去覆盖初始化时创建的block
     */
    if (handler.responseHandleBlock == nil) {
        handler.responseHandleBlock = self.responseHandleBlock;
    }
    return handler;
}
@end
