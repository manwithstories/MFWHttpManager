//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWRequest.h"
#import <Foundation/Foundation.h>

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


- (void)setHeaderParams:(NSDictionary<NSString *,NSString *> *)params
{
    if (params ==nil)
    {
        return;
    }
    
    [self.header_fields removeObjectsForKeys:[params allKeys]];
    [self.header_fields addEntriesFromDictionary:params];
}


- (NSDictionary<NSString *,NSString *> *)httpRequestHeaderFields
{
    return [NSDictionary dictionaryWithDictionary:self.header_fields];
}


@end


@interface MFWRequest ()
@property(nonatomic,strong) NSMutableDictionary *request_params;
@end


@implementation MFWRequest

- (instancetype)init
{
    return [self initWithURLString:@""
                            method:0
                            params:nil];
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
        
        _header = [MFWHttpRequestHeader new];
        _requeustTimeout = 60;
    }
    return self;
}


- (void)modifyParamsWithDict:(NSDictionary *)params
{
    if (params == nil)
    {
        return;
    }
    if (self.request_params == nil)
    {
        self.request_params = [NSMutableDictionary dictionaryWithDictionary:params];
        return;
    }
    [self.request_params removeObjectsForKeys:[params allKeys]];
    [self.request_params addEntriesFromDictionary:params];
}


- (NSDictionary *)params
{
    return [NSDictionary dictionaryWithDictionary:self.request_params];
}

- (void)setParams:(NSDictionary *)params
{
    self.request_params = [NSMutableDictionary dictionaryWithDictionary:params];
}


-(HttpMethod)httpMethod
{
    if (_httpMethod < HttpMethodGet)
    {
        _httpMethod = HttpMethodGet;
    }
    else if (_httpMethod > HttpMethodHead)
    {
        _httpMethod = HttpMethodGet;
    }
    return _httpMethod;
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
            method = @"GET";
            break;
    }
    return method;
}


@end
