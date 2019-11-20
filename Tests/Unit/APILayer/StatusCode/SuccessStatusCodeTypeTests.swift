//
//  InfoStatusCodeTypeTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 18.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class SuccessStatusCodeTypeTests: XCTestCase {

    func testConstructor() {
        let code = StatusCode.Success(222)

        XCTAssertEqual(code?.value, 222)
    }

    func testConstructorForLowestCode() {
        let code = StatusCode.Success(200)

        XCTAssertNotNil(code)
    }

    func testConstructorForHighestCode() {
        let code = StatusCode.Success(299)

        XCTAssertNotNil(code)
    }

    func testConstructorForToLowCode() {
        let code = StatusCode.Success(199)

        XCTAssertNil(code)
    }

    func testConstructorForToHighCode() {
        let code = StatusCode.Success(300)

        XCTAssertNil(code)
    }

    func testEqualityOfEqualCodes() {
        let code1 = StatusCode.Success(202)
        let code2 = StatusCode.Success(202)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = StatusCode.Success(201)
        let code2 = StatusCode.Success(202)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        for i in 200..<299 {
            let code = StatusCode.Success(i)
            XCTAssertNotNil(code?.description)
        }
    }
}
