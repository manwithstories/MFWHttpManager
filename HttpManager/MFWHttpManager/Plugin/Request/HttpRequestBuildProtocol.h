//
//  HttpRequestBuildProtocol.h
//  HttpManager
//
//  Created by william on 15/11/9.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MFWHttpTask;

typedef void(^MFWhttpRequestBuildBlock) (MFWHttpTask *task);

@protocol HttpRequestBuildProtocol <NSObject,NSCopying>

@required
@property (nonatomic, copy) MFWhttpRequestBuildBlock requestBuildBlock;

@end