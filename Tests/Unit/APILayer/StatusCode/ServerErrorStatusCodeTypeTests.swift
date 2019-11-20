//
//  InfoStatusCodeTypeTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 18.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class ServerErrorStatusCodeTypeTests: XCTestCase {

    func testConstructor() {
        let code = StatusCode.ServerError(555)

        XCTAssertEqual(code?.value, 555)
    }

    func testConstructorForLowestCode() {
        let code = StatusCode.ServerError(500)

        XCTAssertNotNil(code)
    }

    func testConstructorForHighestCode() {
        let code = StatusCode.ServerError(599)

        XCTAssertNotNil(code)
    }

    func testConstructorForToLowCode() {
        let code = StatusCode.ServerError(499)

        XCTAssertNil(code)
    }

    func testConstructorForToHighCode() {
        let code = StatusCode.ServerError(600)

        XCTAssertNil(code)
    }

    func testEqualityOfEqualCodes() {
        let code1 = StatusCode.ServerError(502)
        let code2 = StatusCode.ServerError(502)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = StatusCode.ServerError(501)
        let code2 = StatusCode.ServerError(502)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        for i in 500..<599 {
            let code = StatusCode.ServerError(i)
            XCTAssertNotNil(code?.description)
        }
    }
}
