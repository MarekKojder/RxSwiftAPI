//
//  ApiErrorTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 19.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class ApiErrorTests: XCTestCase {
    
    func testNoResponse() {
        let error = Api.Error.noResponse

        XCTAssertFalse(error.localizedDescription.isEmpty)
        XCTAssertNotNil(error.localizedDescription.lowercased().range(of: "response"))
    }

    func testStatusCodeError() {
        let statusCode = StatusCode(400)
        let error1 = Api.Error.error(for: StatusCode(100))
        let error2 = Api.Error.error(for: StatusCode(200))
        let error3 = Api.Error.error(for: StatusCode(300))
        let error4 = Api.Error.error(for: statusCode)
        let error5 = Api.Error.error(for: StatusCode(500))
        let error6 = Api.Error.error(for: StatusCode(600))

        XCTAssertNotNil(error1)
        XCTAssertNil(error2)
        XCTAssertNotNil(error3)
        XCTAssertNotNil(error4)
        XCTAssertNotNil(error5)
        XCTAssertNotNil(error6)
        XCTAssertEqual(error4?.localizedDescription, statusCode.description)
    }
}
