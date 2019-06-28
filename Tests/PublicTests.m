//
//  Tests.m
//  Tests
//
//  Created by Bailey Seymour on 6/27/19.
//  Copyright © 2019 Bailey Seymour. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../libcolorpicker/libcolorpicker.h"

@interface PublicTests : XCTestCase

@end

@implementation PublicTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testHexFromColor {
    NSString *hexToTest;
    
    hexToTest = [UIColor hexFromColor:[UIColor redColor]];
    XCTAssertEqualObjects(@"#FF0000", hexToTest);
    
    hexToTest = [UIColor hexFromColor:[UIColor greenColor]];
    XCTAssertEqualObjects(@"#00FF00", hexToTest);
    
    hexToTest = [UIColor hexFromColor:[UIColor blueColor]];
    XCTAssertEqualObjects(@"#0000FF", hexToTest);
    
    hexToTest = [UIColor hexFromColor:[UIColor whiteColor]];
    XCTAssertEqualObjects(@"#FFFFFF", hexToTest);
    
    hexToTest = [UIColor hexFromColor:[UIColor blackColor]];
    XCTAssertEqualObjects(@"#000000", hexToTest);
}

- (void)testLCPParseColorString {
    UIColor *color;
    
    color = LCPParseColorString(@"#808080", @"#A7A7A7");
    XCTAssertEqualObjects([UIColor hexFromColor:color], @"#808080");
    
    // Test fallback color
    color = LCPParseColorString(nil, @"#A7A7A7");
    XCTAssertEqualObjects([UIColor hexFromColor:color], @"#A7A7A7");
    
    color = LCPParseColorString(@"ioadisodu14", @"#A7A7A7");
    XCTAssertEqualObjects([UIColor hexFromColor:color], @"#A7A7A7");
    
    color = LCPParseColorString(@"#zzzyyy", @"#B9B9B9");
    XCTAssertEqualObjects([UIColor hexFromColor:color], @"#B9B9B9");
    
    color = LCPParseColorString(@"AAAFFF:0.25", @"#A7A7A7");
    XCTAssertEqualObjects([UIColor hexFromColor:color], @"#AAAFFF");
    XCTAssertEqual([color alpha], 0.25);
    
    color = LCPParseColorString(@"#fff:0.5", @"#A7A7A7");
    XCTAssertEqualObjects([UIColor hexFromColor:color], @"#FFFFFF");
    XCTAssertEqual([color alpha], 0.5);
}

- (void)testPFColorAlertInterface {
    XCTAssertTrue([PFColorAlert respondsToSelector:@selector(colorAlertWithStartColor:showAlpha:)]);
    
    XCTAssertTrue([PFColorAlert instancesRespondToSelector:@selector(initWithStartColor:showAlpha:)]);
    
    XCTAssertTrue([PFColorAlert instancesRespondToSelector:@selector(displayWithCompletion:)]);
    
    XCTAssertTrue([PFColorAlert instancesRespondToSelector:@selector(close)]);
}

- (void)testPFLiteColorCell {
    // Jailbreak version only
    XCTAssertTrue([PFLiteColorCell instancesRespondToSelector:@selector(previewColor)]);
    XCTAssertTrue([PFLiteColorCell instancesRespondToSelector:@selector(updateCellDisplay)]);
    XCTAssertTrue([PFLiteColorCell instancesRespondToSelector:@selector(specifier)]);
    XCTAssertTrue([PFLiteColorCell instancesRespondToSelector:@selector(initWithStyle:reuseIdentifier:specifier:)]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
