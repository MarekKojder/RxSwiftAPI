//
//  InfoStatusCodeTypeTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 18.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class RedirectionStatusCodeTypeTests: XCTestCase {

    func testConstructor() {
        let code = StatusCode.Redirection(333)

        XCTAssertEqual(code?.value, 333)
    }

    func testConstructorForLowestCode() {
        let code = StatusCode.Redirection(300)

        XCTAssertNotNil(code)
    }

    func testConstructorForHighestCode() {
        let code = StatusCode.Redirection(399)

        XCTAssertNotNil(code)
    }

    func testConstructorForToLowCode() {
        let code = StatusCode.Redirection(299)

        XCTAssertNil(code)
    }

    func testConstructorForToHighCode() {
        let code = StatusCode.Redirection(400)

        XCTAssertNil(code)
    }

    func testEqualityOfEqualCodes() {
        let code1 = StatusCode.Redirection(302)
        let code2 = StatusCode.Redirection(302)

        XCTAssertTrue(code1 == code2)
    }

    func testEqualityOfNotEqualCodes() {
        let code1 = StatusCode.Redirection(301)
        let code2 = StatusCode.Redirection(302)

        XCTAssertFalse(code1 == code2)
    }

    func testDescription() {
        for i in 300..<399 {
            let code = StatusCode.Redirection(i)
            XCTAssertNotNil(code?.description)
        }
    }
}
