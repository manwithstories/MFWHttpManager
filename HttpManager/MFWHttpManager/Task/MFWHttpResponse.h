//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 MFWHttpResponseHeader - 封装响应头列表
 */
@interface MFWHttpResponseHeader : NSObject

@property (nonatomic, strong, readonly) NSString *set_cookie;
@property (nonatomic, strong, readonly) NSDictionary *cookies;
@property (nonatomic, strong, readonly) NSString *content_type;
@property (nonatomic, strong, readonly) NSString *content_length;
@property (nonatomic, strong, readonly) NSString *etag;
@property (nonatomic, strong, readonly) NSString *last_modified;


- (instancetype)initWithResponseHeaderFields:(NSDictionary *)headerFields;

- (NSDictionary *)httpResponseHeaderFields;


@end


/*
 MFWHttpResponse - 用于封装一个请求的响应数据，包括：statusCode, statusMess, responseHeader, responseObj
 均为可读属性
 可查看返回的JSON数据
 可查看返回的错误状态码及错误信息
 可查看响应头列表
 */
@interface MFWHttpResponse : NSObject

@property(nonatomic, strong,readonly) MFWHttpResponseHeader *header;
@property(nonatomic, strong) id responseData;
@property(nonatomic, strong, readonly) NSString *responseString;
@property(nonatomic, assign, readonly) NSInteger statusCode;
@property(nonatomic, strong, readonly) NSString *statusMessage;


- (instancetype)initWithUrlResponse:(NSURLResponse *)response
                            reponseObj:(id)obj;


@end
