//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpRequest.h"
#import <Foundation/Foundation.h>

static NSString *const cookie_key = @"Cookie";
static NSString *const content_type_key = @"";
static NSString *const content_length_key = @"";
static NSString *const if_none_match_key = @"";
static NSString *const if_modify_since_key = @"";
static NSString *const referer_key = @"";
static NSString *const user_agent_key = @"";

@interface MFWHttpRequestHeader ()

@property (nonatomic, strong) NSMutableDictionary *header_fields;
@end

@implementation MFWHttpRequestHeader

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _header_fields = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setContent_type:(NSString *)content_type
{
    _content_type = content_type;
    [self.header_fields setValue:content_type forKey:content_type_key];
}

- (void)setContent_length:(NSString *)content_length
{
    _content_length = content_length;
    [self.header_fields setValue:content_length forKey:content_length_key];
}

- (void)setIf_none_match:(NSString *)if_none_match
{
    _if_none_match = if_none_match;
    [self.header_fields setValue:if_none_match forKey:if_none_match_key];
}

- (void)setIf_modify_since:(NSString *)if_modify_since
{
    _if_modify_since = if_modify_since;
    [self.header_fields setValue:if_modify_since forKey:if_modify_since_key];
}

- (void)setReferer:(NSString *)referer
{
    _referer = referer;
    [self.header_fields setValue:referer forKey:referer_key];
}

- (void)setUser_agent:(NSString *)user_agent
{
    _user_agent = user_agent;
    [self.header_fields setValue:user_agent forKey:user_agent_key];
}



- (void)setHeaderParams:(NSDictionary *)params
{
    [self.header_fields removeObjectsForKeys:[params allKeys]];
    [self.header_fields addEntriesFromDictionary:params];
}


- (NSDictionary *)httpRequestHeaderFields
{
    return [NSDictionary dictionaryWithDictionary:self.header_fields];
}

@end


@interface MFWHttpRequest ()
@property(nonatomic,strong) NSMutableDictionary *request_params;
@end


@implementation MFWHttpRequest

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _header = [MFWHttpRequestHeader new];
        _request_params = [NSMutableDictionary dictionary];
        _reqeustTimeout = 60;
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString
                           method:(HttpMethod)method
                           params:(NSDictionary *)params;
{
    self = [super init];
    if (self)
    {
        _request_params = [NSMutableDictionary dictionaryWithDictionary:params];
        _URLString = URLString;
        _httpMethod = method;
    }
    return self;
}


- (void)modifyParamsWithDict:(NSDictionary *)params
{
    if (!self.request_params)
    {
        self.request_params = [NSMutableDictionary dictionaryWithDictionary:params];
        return;
    }
    [self.request_params removeObjectsForKeys:[params allKeys]];
    [self.request_params addEntriesFromDictionary:params];
}


- (void)addParamsEntityWithDict:(NSDictionary *)params
{
    if (!self.request_params)
    {
        self.request_params = [NSMutableDictionary dictionaryWithDictionary:params];
        return;
    }
    [self.request_params addEntriesFromDictionary:params];
}


- (NSDictionary *)params
{
    return [NSDictionary dictionaryWithDictionary:self.request_params];
}


- (NSString *)httpMethodString
{
    NSString *method = nil;
    
    switch (self.httpMethod)
    {
        case HttpMethodGet:
            method = @"GET";
            break;
        case HttpMethodPost:
            method = @"POST";
            break;
        case HttpMethodPut:
            method = @"PUT";
            break;
        case HttpMethodDelete:
            method = @"DELETE";
            break;
        case HttpMethodHead:
            method = @"HEAD";
            break;
        case HttpMethodOptions:
            method = @"OPTIONS";
            break;
        default:
            break;
    }
    return method;
}


- (NSString *)requestIdentifier
{
    if (!self.params)
    {
        return self.URLString;
    }
    
    NSData  *paramsJsonData = [NSJSONSerialization dataWithJSONObject:self.params
                                                              options:0
                                                                error:nil];
    
    NSString *paramsString = [[NSString alloc] initWithData:paramsJsonData
                                             encoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"%@%@",self.URLString,paramsString];
    
   
    

    
}


@end
