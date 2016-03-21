//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const cookie_key = @"Cookie";
static NSString *const content_type_key = @"Content-Type";
static NSString *const content_length_key = @"Content-Length";
static NSString *const if_none_match_key = @"If-None-Match";
static NSString *const if_modified_since_key = @"If-Modified-Since";
static NSString *const referer_key = @"Referer";
static NSString *const user_agent_key = @"User-Agent";

/*
  MFWHttpRequestHeader - 请求头的封装， 可用于扩展与修改
 */
@interface MFWHttpRequestHeader : NSObject

- (void)setHeaderParams:(NSDictionary<NSString*,NSString*> *)params;

- (NSDictionary<NSString*,NSString*> *)httpRequestHeaderFields;

@end




/*
  MFWHttpRequest - 用于封装一个请求，包括URL,params,httpMethod,header,reqeustTimeout
  开放了一个请求的唯一标识，
  可以扩展与修改请求头
 */

typedef NS_ENUM(NSUInteger, HttpMethod)
{
    HttpMethodGet = 0,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete,
    HttpMethodOptions,
    HttpMethodHead
};



@interface MFWRequest : NSObject

@property(nonatomic, strong) NSDictionary<NSString *,NSString*> *params;    //请求参数
@property(nonatomic, strong) MFWHttpRequestHeader *header;      //请求头
@property(nonatomic, assign) HttpMethod httpMethod;             //请求方式
@property(nonatomic, strong) NSString *URLString;                     //url
@property(nonatomic, assign) NSTimeInterval requeustTimeout;     //请求过期时间

- (instancetype)initWithURLString:(NSString *)URLString
                           method:(HttpMethod)method
                           params:(NSDictionary<NSString*,NSString*> *)params;


- (void)modifyParamsWithDict:(NSDictionary<NSString*,NSString*> *)params;

- (NSString *)httpMethodString;

@end

