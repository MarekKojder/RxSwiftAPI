//
//  InfoStatusCodeTypeTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 18.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class UnknownStatusCodeTypeTests: XCTestCase {

    func testConstructor() {
        let code = UnknownStatusCodeType(999)

        XCTAssertEqual(code.value, 999)
    }

    func testEqualityOfEqualCodes() {
        let code1 = UnknownStatusCodeType(0)
        let code2 = UnknownStatusCodeType(0)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = UnknownStatusCodeType(-1)
        let code2 = UnknownStatusCodeType(1)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        let code = UnknownStatusCodeType(0)
        XCTAssertNotNil(code.description)
    }
}
