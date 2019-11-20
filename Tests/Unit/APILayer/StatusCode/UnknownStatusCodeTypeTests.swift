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
        let code = StatusCode.Unknown(999)

        XCTAssertEqual(code.value, 999)
    }

    func testEqualityOfEqualCodes() {
        let code1 = StatusCode.Unknown(0)
        let code2 = StatusCode.Unknown(0)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = StatusCode.Unknown(-1)
        let code2 = StatusCode.Unknown(1)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        let code = StatusCode.Unknown(0)
        XCTAssertNotNil(code.description)
    }
}
