//  Created by MFWMobile on 14-1-22.
//  Copyright (c) 2014年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFWHttpTask.h"

@interface MFWResponseBaseHandler : NSObject <HttpResponseHandleProtocol>

+ (id<HttpResponseHandleProtocol>)handler;

@end
