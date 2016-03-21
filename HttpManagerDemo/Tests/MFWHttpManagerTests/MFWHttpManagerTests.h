//
//  MFWHttpManagerTests.h
//  HttpManager
//
//  Created by chuyanling on 15/12/30.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface MFWHttpManagerTests : GHTestCase

@property (nonatomic, strong) NSString *test_request_url;

- (NSString *)errorInfoWith:(NSString *)error
                  className:(NSString *)name;

@end
