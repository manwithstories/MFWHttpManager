//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
  MFWHttpRequestHeader - 请求头的封装， 可用于扩展与修改
 */
@interface MFWHttpRequestHeader : NSObject
//cookie  数据的读取与缓存 ----- ？？？？
@property (nonatomic, strong, readonly) NSString *cookie;
@property (nonatomic, strong, readonly) NSDictionary *cookies;
// -------

@property (nonatomic, strong) NSString *content_type;
@property (nonatomic, strong) NSString *content_length;
@property (nonatomic, strong) NSString *if_none_match;
@property (nonatomic, strong) NSString *if_modify_since;
@property (nonatomic, strong) NSString *referer;
@property (nonatomic, strong) NSString *user_agent;

- (void)setHeaderParams:(NSDictionary *)params;

- (NSDictionary *)httpRequestHeaderFields;

@end




/*
  MFWHttpRequest - 用于封装一个请求，包括URL,params,httpMethod,header,reqeustTimeout
  开放了一个请求的唯一标识，
  可以扩展与修改请求头
 */

typedef NS_ENUM(NSUInteger, HttpMethod)
{
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodTrace,
    HttpMethodPatch,
    HttpMethodDelete,
    HttpMethodOptions,
    HttpMethodHead
};



@interface MFWHttpRequest : NSObject

@property(nonatomic, strong) NSDictionary *params;    //请求参数
@property(nonatomic, strong) MFWHttpRequestHeader *header;      //请求头
@property(nonatomic, assign) HttpMethod httpMethod;             //请求方式
@property(nonatomic, strong) NSString *URLString;                     //url
@property(nonatomic, assign) NSTimeInterval reqeustTimeout;     //请求过期时间


- (instancetype)initWithURLString:(NSString *)URLString
                           method:(HttpMethod)method
                           params:(NSDictionary *)params;


- (void)modifyParamsWithDict:(NSDictionary *)params;

- (void)addParamsEntityWithDict:(NSDictionary *)params;

- (NSString *)httpMethodString;

//返回该请求的唯一标识
- (NSString *)requestIdentifier;


@end
