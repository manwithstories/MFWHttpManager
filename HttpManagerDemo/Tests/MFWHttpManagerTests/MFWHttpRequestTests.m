//
//  MFWHttpRequestTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/24.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"
#import "MFWRequest.h"

/* 
  MFWHttpRequest - 用于封装一个请求，包括URL,params,httpMethod,header,reqeustTimeout
  MFWHttpRequestTests  - 主要对公共属性（setter & getter）和公共方法进行正确性和健壮性测试，以及枚举类型的边界测试
 */
@interface MFWHttpRequestTests : MFWHttpManagerTests

@end



@implementation MFWHttpRequestTests

- (void)setUpClass
{
    [super setUpClass];
}



/*
  目的：测试MFWHttpRequest 对象的 - 所有公共属性的数据 - 是否正确
  方式：创建request 对象并且赋值，判断所有公共属性的输出值是否等于输入值
 */
- (void)testPropertiesAreGetterCorrectly
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:HttpMethodPost
                                       params:@{@"key":@"value"}];
    
    GHAssertTrue(request.httpMethod == HttpMethodPost,[self errorInfoWith:@"httpMethod property"
                                                                className:@"MFWHttpRequest"]);
    
    GHAssertEqualObjects([request httpMethodString], @"POST", [self errorInfoWith:@"httpMethodString method"
                                                                  className:@"MFWHttpRequest"]);
    
    GHAssertEqualObjects(request.params[@"key"], @"value", [self errorInfoWith:@"params property"
                                                               className:@"MFWHttpRequest"]);
    
    GHAssertEqualObjects(request.URLString, self.test_request_url, [self errorInfoWith:@"URLString property"
                                                                       className:@"MFWHttpRequest"]);
}


- (void)testPropertiesAreSetterCorrectly
{
//    MFWRequest *request = [MFWRequest new];
//    
//    request.httpMethod = HttpMethodPut;
//    NSString *method_string = [request httpMethodString];
//    GHAssertEqualObjects(method_string, @"PUT", @"httpMethodString  value is error");
//    GHAssertTrue(request.httpMethod == HttpMethodPut, @"httpMethod value is error");
//    
//    request.URLString = self.test_request_url;
//    GHAssertEqualObjects(request.URLString, self.test_request_url, @"URLString value is error");
//    
//    request.reqeustTimeout = 10;
//    GHAssertTrue(request.reqeustTimeout == 10, @"reqeustTimeout value is error");
//    
//    request.params = @{@"key":@"value"};
//    request.params = @{@"key":@"reset"};
//    GHAssertEqualObjects(request.params[@"key"], @"reset", @"params is error");
//    GHAssertTrue([[request.params allKeys] count] == 1, @"params is error");
    
}


#pragma mark - httpMethod 类型边界测试
/*
 目的: MFWHttpRequest对象 -  httpMethod 类型边界测试
 方式.1: 方法类型为-1时，判断方法类型是否是默认类型
 方式.2: 方法为1000时, 判断方法类型是否是默认类型
 方式.2: 设置方法类型，判断方法类型是否正确
 */
- (void)testHttpMethodWhenIsOverflow
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:-1
                                       params:nil];
    
    NSString *method_string = [request httpMethodString];
    
    GHAssertEqualObjects(method_string, @"GET", @"httpMethod should have default value");
    GHAssertTrue(request.httpMethod == HttpMethodGet, @"httpMethod should have default value");
    //
    request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:1000
                                       params:nil];
    
    method_string = [request httpMethodString];
    
    GHAssertEqualObjects(method_string, @"GET", @"httpMethod should have default value");
    GHAssertTrue(request.httpMethod == HttpMethodGet, @"httpMethod should have default value");
   
    //
    request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:3
                                       params:nil];
    
    method_string = [request httpMethodString];
    
    GHAssertEqualObjects(method_string, @"DELETE", @"httpMethodString value is error");
    GHAssertTrue(request.httpMethod == HttpMethodDelete, @"httpMethod value is error");
}



#pragma mark - MFWHttpRequestHeader setHeaderParams 方法测试用例

/*
  目的:测试MFWHttpRequest 的 - setHeaderParams 请求头的数据赋值方法 - 是否正确
  方式:以请求头的公共属性为key来拼装字典，并判断key-value输出值是否等于输入值
 */
- (void)testHeaderSetHeaderParamsWithPropertyKey
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:0
                                       params:nil];
    
    NSString *contentTypeValue = @"application/x-www-form-urlencoded";
    NSString *userAgentValue = @"Mozilla/5.0 (Linux; X11)";
    NSString *cookieValue = @"$Version=1; Skin=new";
    NSString *contentLengthValue = @"348";
    NSString *ifNoneMatchValue = @"737060cd8c284d8af7ad3082f209582d";
    NSString *ifModifiedSinceValue = @"Tur, 5 JAN 2016 14:38:30 GMT";
    NSString *refererValue = @"http://www.mafengwo.cn";
    
    
    [request.header setHeaderParams:@{content_type_key:contentTypeValue}];
    [request.header setHeaderParams:@{user_agent_key:userAgentValue}];
    [request.header setHeaderParams:@{cookie_key:cookieValue,
                                      content_length_key:contentLengthValue,
                                      if_none_match_key:ifNoneMatchValue,
                                      if_modified_since_key:ifModifiedSinceValue,
                                      referer_key:refererValue}];
    
    NSDictionary *httpHeaderFileds = [request.header httpRequestHeaderFields];
    NSString *error = @"headerFileds setting key is error";
    
    GHAssertEqualObjects(httpHeaderFileds[@"Content-Type"],
                         contentTypeValue,
                         [NSString stringWithFormat:@"%@--%@",content_type_key,error]);
    
    GHAssertEqualObjects(httpHeaderFileds[@"User-Agent"],
                         userAgentValue,
                         [NSString stringWithFormat:@"%@--%@",user_agent_key,error]);
    
    GHAssertEqualObjects(httpHeaderFileds[@"Cookie"],
                         cookieValue,
                         [NSString stringWithFormat:@"%@--%@",cookie_key,error]);
    
    GHAssertEqualObjects(httpHeaderFileds[@"Content-Length"],
                         contentLengthValue,
                         [NSString stringWithFormat:@"%@--%@",content_length_key,error]);
    
    GHAssertEqualObjects(httpHeaderFileds[@"If-None-Match"],
                         ifNoneMatchValue,
                         [NSString stringWithFormat:@"%@--%@",if_none_match_key,error]);
    
    GHAssertEqualObjects(httpHeaderFileds[@"If-Modified-Since"],
                         ifModifiedSinceValue,
                         [NSString stringWithFormat:@"%@--%@",if_modified_since_key,error]);
    
    GHAssertEqualObjects(httpHeaderFileds[@"Referer"],
                         refererValue,
                         [NSString stringWithFormat:@"%@--%@",referer_key,error]);

}



/*
 目的:测试MFWHttpRequest 的 -setHeaderParams 请求头的数据赋值方法 - 是否正确
 方式:以字符串为key来拼装字典，并判断key-value输出值是否等于输入值
 */
- (void)testHeaderSetHeaderParamsWithStringKey
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:0
                                       params:nil];
    
    NSString *contentTypeValue = @"application/x-www-form-urlencoded";
    NSString *userAgentValue = @"Mozilla/5.0 (Linux; X11)";
    [request.header setHeaderParams:@{@"User-Agent":userAgentValue}];
    [request.header setHeaderParams:@{@"Content-Type":contentTypeValue}];

    NSDictionary *httpHeaderFileds = [request.header httpRequestHeaderFields];
    GHAssertEqualObjects(httpHeaderFileds[@"User-Agent"],
                         userAgentValue,
                         @"headerFileds setting is error");
    
    GHAssertEqualObjects(httpHeaderFileds[@"Content-Type"],
                         contentTypeValue,
                         @"headerFileds setting is error");
    
}


/*
 目的:测试MFWHttpRequest 的 - setHeaderParams请求头的数据赋值方法 - 是否健壮
 方式.1:字典为nil,判断是否正常
 方式.2:字典为空, 判断是否正常
 */
- (void)testHeaderSetHeaderParamsDictWithParamNil
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:0
                                       params:nil];
    
    //
    [request.header setHeaderParams:nil];
    NSDictionary *httpHeaderFileds = [request.header httpRequestHeaderFields];
    GHAssertTrue([[httpHeaderFileds allKeys] count] == 0, @"headerFileds setting is error");
    //
    [request.header setHeaderParams:@{}];
    httpHeaderFileds = [request.header httpRequestHeaderFields];
    GHAssertTrue([[httpHeaderFileds allKeys] count] == 0, @"headerFileds setting is error");
    
}


#pragma mark- modifyParamsWithDict 方法测试用例

/*
 目的：测试MFWHttpRequest对象 - modifyParamsWithDict 修改请求参数方法 - 是否正确
 方式.1：对已有的请求参数进行修改，并判断修改后的输出值和输入值是否相等
 方式.2：添加部分未设置的请求参数key-value，并判断方法调用后，输出值与输入值是否相等
 */
- (void)testModifyParamsDictWithParams
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:0
                                       params:@{@"key":@"value"}];
    //
    [request modifyParamsWithDict:@{@"key":@"reset"}];
    GHAssertEqualObjects(request.params[@"key"], @"reset", @"modify params by modifyParamsWithDict Method is failed");
    //
    [request modifyParamsWithDict:@{@"otherKey":@"otherValue"}];
    GHAssertEqualObjects(request.params[@"otherKey"], @"otherValue", @"add params by modifyParamsWithDict Method is failed");
   
    //
    [request modifyParamsWithDict:@{@"otherKey":@"",
                                    @" ":@"anotherValue"}];
    
    GHAssertEqualObjects(request.params[@"otherKey"], @"", @"modify params by modifyParamsWithDict Method is failed");
    GHAssertEqualObjects(request.params[@" "], @"anotherValue", @"add params by modifyParamsWithDict Method is failed");
    GHAssertTrue([[request.params allKeys] count] == 3, @"params count is error");
}


/*
 目的:测试MFWHttpRequest对象 - modifyParamsWithDict请求头的数据赋值方法 - 是否健壮
 方式.1:字典为nil,判断是否正常
 方式.2:字典为空, 判断是否正常
 */
- (void)testModifyParamsDictWithParamNil
{
    MFWRequest *request =
    [[MFWRequest alloc] initWithURLString:self.test_request_url
                                       method:0
                                       params:@{@"key":@"value"}];
    [request modifyParamsWithDict:nil];
    GHAssertEqualObjects(request.params[@"key"], @"value", @"modify nil by modifyParamsWithDict Method is failed");
    [request modifyParamsWithDict:@{}];
    GHAssertEqualObjects(request.params[@"key"], @"value", @"modify @{} by modifyParamsWithDict Method is failed");

}


@end
