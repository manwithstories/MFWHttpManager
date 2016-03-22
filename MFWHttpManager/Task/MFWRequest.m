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
                           method:(MFWRequestHttpMethod)method
                           params:(NSDictionary *)params;
{
    self = [super init];
    if (self)
    {
        _request_params = [NSMutableDictionary dictionaryWithDictionary:params];
        _URLString = URLString;
        _httpMethod = method;
        
        _header = [MFWHttpRequestHeader new];
        _requestTimeout = 60;
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


-(MFWRequestHttpMethod)httpMethod
{
    if (_httpMethod < MFWRequestHttpMethodGet)
    {
        _httpMethod = MFWRequestHttpMethodGet;
    }
    else if (_httpMethod > MFWRequestHttpMethodHead)
    {
        _httpMethod = MFWRequestHttpMethodGet;
    }
    return _httpMethod;
}



- (NSString *)httpMethodString
{
    NSString *method = nil;
    
    switch (self.httpMethod)
    {
        case MFWRequestHttpMethodGet:
            method = @"GET";
            break;
        case MFWRequestHttpMethodPost:
            method = @"POST";
            break;
        case MFWRequestHttpMethodPut:
            method = @"PUT";
            break;
        case MFWRequestHttpMethodDelete:
            method = @"DELETE";
            break;
        case MFWRequestHttpMethodHead:
            method = @"HEAD";
            break;
        case MFWRequestHttpMethodOptions:
            method = @"OPTIONS";
            break;
        default:
            method = @"GET";
            break;
    }
    return method;
}


@end
