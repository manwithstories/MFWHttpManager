//
//  MFWHttpManager.h
//  HttpManagerDemo
//
//  Created by 刘澈 on 16/3/21.
//  Copyright © 2016年 刘澈. All rights reserved.
//

//任务
#import "MFWHttpDataTask.h"
#import "MFWRequest.h"
#import "MFWResponse.h"

//插件
#import "MFWResponseHandlerPipeline.h"
#import "MFWRequestBuilderPipeline.h"
#import "MFWRequestBaseBuilder.h"
#import "MFWResponseBaseHandler.h"

//流水线处理引擎
#import "MFWHttpTaskEngine.h"


#if DEBUG
#define  MFWHttpManagerAssert(condition,fmt,...) \
if(!(condition)) {\
NSAssert(NO,fmt, ##__VA_ARGS__);\
}
#else
#define  MFWHttpManagerAssert(condition,fmt,...) \
if(!(condition)) {\
NSLog((@"crush in debug :%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);\
}
#endif



@interface MFWHttpManager : NSObject

+ (MFWHttpTaskEngine *)defaultEngine;

@end