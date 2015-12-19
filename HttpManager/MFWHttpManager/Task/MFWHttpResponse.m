//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWHttpResponse.h"

static NSString * const set_cookie_key = @"Set-Cookie";
static NSString * const cookies_key = @"";
static NSString * const content_type_key = @"Content-Type";
static NSString * const content_length_key = @"Content-Length";
static NSString * const last_modified_key = @"Last-Modified";

@interface MFWHttpResponseHeader ()

@property (nonatomic, strong) NSDictionary *header_fields;

@end

@implementation MFWHttpResponseHeader

- (instancetype)initWithResponseHeaderFields:(NSDictionary *)headerFields
{
    self = [super init];
    if (self)
    {
        self.header_fields = [NSDictionary dictionaryWithDictionary:headerFields];
    }
    return self;
}

- (NSString *)set_cookie
{
    return [_header_fields objectForKey:set_cookie_key];
}

- (NSString *)content_type
{
    return [_header_fields objectForKey:content_type_key];
}

- (NSString *)content_length
{
    return [_header_fields objectForKey:content_length_key];
}

- (NSString *)last_modified
{
    return [_header_fields objectForKey:last_modified_key];
}

- (NSDictionary *)httpResponseHeaderFields
{
    return self.header_fields;
}


- (NSString *)description
{
    return @"";
}


@end

@interface MFWHttpResponse ()

@property (nonatomic, strong) NSHTTPURLResponse *urlResponse;
@property (nonatomic, strong) MFWHttpResponseHeader *header;

@end


@implementation MFWHttpResponse


- (instancetype)initWithUrlResponse:(NSURLResponse *)response
                         reponseObj:(id)obj
{
    self = [super init];
    if (self)
    {
        _urlResponse = (NSHTTPURLResponse *)response;
        _responseData = obj;
    }
    return self;
}


-(NSString *)responseString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.responseData
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:nil];
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    return string;
}


- (NSInteger)statusCode
{
    if (self.urlResponse)
    {
        return self.urlResponse.statusCode;
    }
    
    return -1;
}



- (MFWHttpResponseHeader *)header
{
    if (!_header && self.urlResponse)
    {
        _header = [[MFWHttpResponseHeader alloc] initWithResponseHeaderFields:[_urlResponse allHeaderFields]];
    }
    return _header;
}



@end
