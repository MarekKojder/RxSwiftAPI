//
//  InfoStatusCodeTypeTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 18.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class ClientErrorStatusCodeTypeTests: XCTestCase {

    func testConstructor() {
        let code = StatusCode.ClientError(444)

        XCTAssertEqual(code?.value, 444)
    }

    func testConstructorForLowestCode() {
        let code = StatusCode.ClientError(400)

        XCTAssertNotNil(code)
    }

    func testConstructorForHighestCode() {
        let code = StatusCode.ClientError(499)

        XCTAssertNotNil(code)
    }

    func testConstructorForToLowCode() {
        let code = StatusCode.ClientError(399)

        XCTAssertNil(code)
    }

    func testConstructorForToHighCode() {
        let code = StatusCode.ClientError(500)

        XCTAssertNil(code)
    }

    func testEqualityOfEqualCodes() {
        let code1 = StatusCode.ClientError(402)
        let code2 = StatusCode.ClientError(402)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = StatusCode.ClientError(401)
        let code2 = StatusCode.ClientError(402)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        for i in 400..<499 {
            let code = StatusCode.ClientError(i)
            XCTAssertNotNil(code?.description)
        }
    }
}
