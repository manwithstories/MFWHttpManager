//
//  MFWHttpManager.m
//  HttpManagerDemo
//
//  Created by 刘澈 on 16/3/21.
//  Copyright © 2016年 刘澈. All rights reserved.
//

#import "MFWHttpManager.h"

@implementation MFWHttpManager

+ (MFWHttpTaskEngine *)defaultEngine
{
    static MFWHttpTaskEngine *fs_default = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fs_default = [[MFWHttpTaskEngine alloc] init];
    });
    return fs_default;
}

@end