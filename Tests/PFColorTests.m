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
    PFColor *color = [[PFColor alloc] initWithHex:@"#8c738c"];
    XCTAssertEqualObjects([color hexString], @"#8C738C");
    
    NSLog(@"ORIG COLOR: %@", color);
    
    CGFloat origRed, origGreen, origBlue, origAlpha;
    
    origRed = color.red;
    origGreen = color.green;
    origBlue = color.blue;
    origAlpha = color.alpha;
    
    CGFloat origH, origS, origB;
    
    origH = color.hue;
    origS = color.saturation;
    origB = color.brightness;
    NSLog(@"hue: %g", color.hue);
    NSLog(@"saturation: %g", color.saturation);
    NSLog(@"brightness: %g", color.brightness);
    
    [color setValuesFromHex:@"#5fba7d"];
    
    NSLog(@"TEST HEX: %@", color);

    [color setHue:origH];
    XCTAssertEqual(origH, color.hue);
    
    [color setSaturation:origS];
    XCTAssertEqualWithAccuracy(origS, color.saturation, 0.0000001);
    
    [color setBrightness:origB];
    XCTAssertEqual(origB, color.brightness);
    
    NSLog(@"hue: %g", color.hue);
    
    NSLog(@"NEW COLOR: %@", color);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
