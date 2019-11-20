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
        XCTAssertEqual(Api.Method.get.httpMethod, Http.Method.get)
        XCTAssertEqual(Api.Method.post.httpMethod, Http.Method.post)
        XCTAssertEqual(Api.Method.put.httpMethod, Http.Method.put)
        XCTAssertEqual(Api.Method.patch.httpMethod, Http.Method.patch)
        XCTAssertEqual(Api.Method.delete.httpMethod, Http.Method.delete)
    }
}
