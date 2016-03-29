//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString * const set_cookie_key = @"Set-Cookie";
static NSString * const re_content_type_key = @"Content-Type";
static NSString * const re_content_length_key = @"Content-Length";
static NSString * const last_modified_key = @"Last-Modified";


/*
 MFWHttpResponseHeader - 封装响应头列表
 */
@interface MFWHttpResponseHeader : NSObject

- (NSDictionary<NSString*, NSString*> *)httpResponseHeaderFields;

@end


/*
 MFWHttpResponse - 用于封装一个请求的响应数据，包括：statusCode, statusMess, responseHeader, responseObj
 均为可读属性
 可查看返回的JSON数据
 可查看返回的错误状态码及错误信息
 可查看响应头列表
 */
@interface MFWResponse : NSObject

@property(nonatomic, strong, readonly) MFWHttpResponseHeader *header;
@property(nonatomic, strong, readonly) NSData *responseData;
@property(nonatomic, strong, readonly) NSString *responseString;
@property(nonatomic, strong, readonly) NSDictionary *responseDcit;
@property(nonatomic, assign, readonly) NSInteger statusCode;


- (instancetype)initWithUrlResponse:(NSURLResponse *)response
                       responseData:(NSData *)data;


@end
