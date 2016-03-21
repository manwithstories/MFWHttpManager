//
//  MFWHttpResponseTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/24.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"
#import "MFWResponse.h"
#import "MFWHttpDataTask.h"
#import "MFWHttpTaskAFNEngine.h"
#import "MFWHttpTaskEngine.h"

/*
 MFWHttpResponse - 用于封装一个请求的响应数据，包括：statusCode, statusMess, responseHeader, responseObj
 均为可读属性
 MFWHttpResponseTests - 主要是对属性进行getter 测试
 */

@interface MFWHttpResponseTests : MFWHttpManagerTests

@end


@implementation MFWHttpResponseTests

-(void)setUpClass
{
    [super setUpClass];
}


/*
  目的: 测试MFWHttpResponse 对象 - 所有公共属性的数据 - 是否正确
  方式.1: response 为nil时，判断所有公共属性的输出值是否为默认值
  方式.2: 创建response 对象并进行赋值，判断所有公共属性的输出值是否等于输入值
 */

- (void)testPropertiesAreGetterCorrectly
{
//    NSHTTPURLResponse *testResponse =
//    [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:self.test_request_url]
//                                statusCode:200
//                               HTTPVersion:@"1.1"
//                              headerFields:@{@"Connection" : @"Keep-Alive",
//                                             @"Content-Length" : @"7434",
//                                             @"Content-Type" : @"application/json",
//                                             @"Date" : @"Tue, 05 Jan 2016 08:47:49 GMT",
//                                             @"Keep-Alive" : @"timeout=5, max=100",
//                                             @"Server" : @"Apache/2.4.9 (Unix) OpenSSL/1.0.1g PHP/5.4.27 mod_perl/2.0.8-dev Perl/v5.16.3",
//                                             @"X-Powered-By" : @"PHP/5.4.27"}];
//    
//    
//    MFWResponse *testMFWHttpResponse =
//    [[MFWResponse alloc] initWithUrlResponse:testResponse
//                                      reponseObj:nil];
//    
//    GHAssertTrue(testMFWHttpResponse.statusCode == 200, @"statusCode property is error");
//    
//    GHAssertNil(testMFWHttpResponse.responseData, @"responseData property default value should be nil");
//    GHAssertEqualObjects(testMFWHttpResponse.responseDcit, [NSDictionary dictionary], @"responseDict default value is error");
//    GHAssertEqualObjects(testMFWHttpResponse.responseString, @"", @"responseString default value is error");
//
//    
//    //
//    MFWHttpTaskEngine *taskEngine = [MFWHttpTaskEngine engineWithSingleIdentifier:@"MFWHttpResponseTestsEngine"];
//    [taskEngine executeTask:[MFWHttpDataTask taskWithURLString:self.test_request_url
//                                                    method:HttpMethodGet
//                                                    params:nil
//                                                  taskType:HttpTaskTypeRequest]
//                complection:^(BOOL succeed, BOOL cancelled, id responeseData, NSError *error) {
//                    if (!succeed)
//                    {
//                        return;
//                    }
//                    MFWResponse *otherResponse =
//                    [[MFWResponse alloc] initWithUrlResponse:testResponse
//                                                      reponseObj:responeseData];
//                    GHAssertNotEqualObjects(otherResponse.responseDcit,
//                                            [NSDictionary dictionary],
//                                            @"responseDict value is error");
//                    GHAssertNotEqualObjects(otherResponse.responseString,
//                                            @"",
//                                            @"responseString value is error");
//                }];
    
}



/*
 目的: 测试MFWHttpResponse header对象 - httpResponseHeaderFields -数据是否正确
 方式: 创建response 对象，并设置response 的header，判断所有属性的输出值是否等于输入值
 */
- (void)testHttpResponseHeaderFieldsAreGetterCorrectly
{
    NSHTTPURLResponse *testResponse =
    [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:self.test_request_url]
                                statusCode:200
                               HTTPVersion:@"1.1"
                              headerFields:@{@"Connection" : @"Keep-Alive",
                                             @"Content-Length" : @"7434",
                                             @"Content-Type" : @"application/json",
                                             @"Date" : @"Tue, 05 Jan 2016 08:47:49 GMT",
                                             @"Keep-Alive" : @"timeout=5, max=100",
                                             @"Server" : @"Apache/2.4.9 (Unix) OpenSSL/1.0.1g PHP/5.4.27 mod_perl/2.0.8-dev Perl/v5.16.3",
                                             @"X-Powered-By" : @"PHP/5.4.27"}];
    
    
    MFWResponse *testMFWHttpResponse =
    [[MFWResponse alloc] initWithUrlResponse:testResponse
                                      reponseObj:nil];
    
    MFWHttpResponseHeader *testHeader = testMFWHttpResponse.header;
    NSDictionary *testHeaderDict = [testHeader httpResponseHeaderFields];
    
    GHAssertEqualObjects(testHeaderDict[re_content_type_key], @"application/json", [NSString stringWithFormat:@"Content-Type is error ---%@",re_content_type_key]);
    GHAssertEqualObjects(testHeaderDict[re_content_length_key], @"7434", [NSString stringWithFormat:@"Content-Length is error ---%@",re_content_length_key]);
    GHAssertEqualObjects(testHeaderDict[@"Connection"], @"Keep-Alive", @"header");
    
}



- (void)tearDownClass
{
    
}

@end
