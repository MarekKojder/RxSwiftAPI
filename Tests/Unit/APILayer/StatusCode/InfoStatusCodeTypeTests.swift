//
//  InfoStatusCodeTypeTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 18.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class InfoStatusCodeTypeTests: XCTestCase {

    func testConstructor() {
        let code = StatusCode.Info(111)

        XCTAssertEqual(code?.value, 111)
    }

    func testConstructorForLowestCode() {
        let code = StatusCode.Info(100)

        XCTAssertNotNil(code)
    }

    func testConstructorForHighestCode() {
        let code = StatusCode.Info(199)

        XCTAssertNotNil(code)
    }

    func testConstructorForToLowCode() {
        let code = StatusCode.Info(99)

        XCTAssertNil(code)
    }

    func testConstructorForToHighCode() {
        let code = StatusCode.Info(200)

        XCTAssertNil(code)
    }

    func testEqualityOfEqualCodes() {
        let code1 = StatusCode.Info(102)
        let code2 = StatusCode.Info(102)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = StatusCode.Info(101)
        let code2 = StatusCode.Info(102)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        for i in 100..<199 {
            let code = StatusCode.Info(i)
            XCTAssertNotNil(code?.description)
        }
    }
}
