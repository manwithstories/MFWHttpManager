//
//  MFWHttpManagerTests.m
//  HttpManager
//
//  Created by chuyanling on 15/12/30.
//  Copyright © 2015年 刘澈. All rights reserved.
//

#import "MFWHttpManagerTests.h"

@implementation MFWHttpManagerTests

- (void)setUpClass
{
    self.test_request_url = @"http://182.92.72.114/source/plugin/aimdev/api/simulate/simulatelist.php";
}


- (void)setUp
{
    
}


- (NSString *)errorInfoWith:(NSString *)error className:(NSString *)name;
{
    return [NSString stringWithFormat:@"Error for %@ in %@",error,name];
}



- (void)tearDown
{
    
}


- (void)tearDownClass
{
    
}


@end
