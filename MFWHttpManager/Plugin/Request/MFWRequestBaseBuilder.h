//  Created by MFWMobile on 15/8/26.
//  Copyright © 2015年 MFWMobLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFWHttpDataTask.h"

@interface MFWRequestBaseBuilder : NSObject <HttpRequestBuildProtocol>

+ (id<HttpRequestBuildProtocol>)builder;

@end
