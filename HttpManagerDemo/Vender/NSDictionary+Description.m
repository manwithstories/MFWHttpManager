//
//  NSDictionary+Description.m
//  HttpManager
//
//  Created by chuyanling on 15/10/15.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "NSDictionary+Description.h"
#import <objc/runtime.h>


@implementation NSDictionary (Description)


+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSel = @selector(description);
        SEL newSel = @selector(newDescription);
        Method origin_method = class_getInstanceMethod([self class], originSel);
        Method new_method = class_getInstanceMethod([self class], newSel);
        
        BOOL isSuccess = class_addMethod([self class],
                                         newSel,
                                         method_getImplementation(new_method),
                                         method_getTypeEncoding(origin_method));
        if (isSuccess)
        {
            class_replaceMethod([self class],
                                originSel,
                                method_getImplementation(new_method),
                                method_getTypeEncoding(origin_method));
        }
        else
        {
            method_exchangeImplementations(origin_method,
                                           new_method);
        }
        
        
    });
    
}


- (NSString *)newDescription
{
    NSString *desc = [self newDescription];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding]
                              encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}





@end
