//
//  ApiMethodTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 02.08.2017.
//

import XCTest
@testable import RxSwiftAPI

class ApiMethodTests: XCTestCase {
    
    func testConvertingToHttpMethod() {
        XCTAssertEqual(ApiMethod.get.httpMethod, Http.Method.get)
        XCTAssertEqual(ApiMethod.post.httpMethod, Http.Method.post)
        XCTAssertEqual(ApiMethod.put.httpMethod, Http.Method.put)
        XCTAssertEqual(ApiMethod.patch.httpMethod, Http.Method.patch)
        XCTAssertEqual(ApiMethod.delete.httpMethod, Http.Method.delete)
    }
}
