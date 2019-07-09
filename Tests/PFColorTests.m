//
//  PFColorTests.m
//  libcolorpicker_appstore_tests
//
//  Created by Bailey Seymour on 7/9/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../libcolorpicker/PFColor.h"

@interface PFColorTests : XCTestCase

@end

@implementation PFColorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPFColor {
    PFColor *color = [[PFColor alloc] initWithHex:@"#ff0000"];
    XCTAssertEqualObjects([color hexString], @"#FF0000");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
