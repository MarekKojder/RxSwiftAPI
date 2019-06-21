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
        XCTAssertEqual(ApiMethod.get.httpMethod, HttpMethod.get)
        XCTAssertEqual(ApiMethod.post.httpMethod, HttpMethod.post)
        XCTAssertEqual(ApiMethod.put.httpMethod, HttpMethod.put)
        XCTAssertEqual(ApiMethod.patch.httpMethod, HttpMethod.patch)
        XCTAssertEqual(ApiMethod.delete.httpMethod, HttpMethod.delete)
    }
}
