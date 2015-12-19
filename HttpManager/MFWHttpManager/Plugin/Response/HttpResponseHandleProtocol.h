//
//  HttpResponseHandleProtocol.h
//  HttpManager
//
//  Created by william on 15/11/9.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MFWHttpTask;

//response plugin
typedef void(^MFWHttpResponseHandleBlock) (MFWHttpTask *task);
@protocol HttpResponseHandleProtocol <NSObject,NSCopying>

@required
@property (nonatomic,copy) MFWHttpResponseHandleBlock responseHandleBlock;
@property (nonatomic,assign) BOOL inBackgroundRun;

@end
