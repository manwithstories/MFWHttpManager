//  Created by MFWMobile on 15/8/18.
//  Copyright (c) 2015年 MFWMobile. All rights reserved.
//

#import "MFWResponse.h"

@interface MFWHttpResponseHeader ()

@property (nonatomic, strong) NSDictionary *header_fields;

- (instancetype)initWithResponseHeaderFields:(NSDictionary *)headerFields;

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


- (NSDictionary *)httpResponseHeaderFields
{
    return self.header_fields;
}

@end



@interface MFWResponse ()

@property (nonatomic, strong) NSHTTPURLResponse *urlResponse;
@property (nonatomic, strong) MFWHttpResponseHeader *header;

@end


@implementation MFWResponse


- (instancetype)initWithUrlResponse:(NSURLResponse *)response
                       responseData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        _urlResponse = (NSHTTPURLResponse *)response;
        _responseData = data;
        _header = nil;
    }
    return self;
}

- (NSDictionary *)responseDcit
{
    if (self.responseData == nil)
    {
        return [NSDictionary dictionary];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.responseData
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    if (data == nil)
    {
        return [NSDictionary dictionary];
    }
    
    NSDictionary *responseInfoDict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                          error:nil];
    return responseInfoDict;
    
}


-(NSString *)responseString
{
    if (self.responseData == nil)
    {
        return @"";
    }
    
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
    if (_header==nil && self.urlResponse)
    {
        _header = [[MFWHttpResponseHeader alloc] initWithResponseHeaderFields:[_urlResponse allHeaderFields]];
    }
    return _header;
}



@end
