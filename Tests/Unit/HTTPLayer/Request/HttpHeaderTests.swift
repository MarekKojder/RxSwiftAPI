//
//  HttpHeaderTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 24.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class HttpHeaderTests: XCTestCase {

    func testHashValue() {
        let header1 = Http.Header(name: "Header1", value: "Value1")
        let header2 = Http.Header(name: "Header2", value: "Value2")

        XCTAssertTrue(header1.hashValue == header1.hashValue)
        XCTAssertFalse(header1.hashValue == header2.hashValue)
    }

    func testEqualityOfEqualHeaders() {
        let header1 = Http.Header(name: "Header1", value: "Value1")
        let header2 = Http.Header(name: "Header1", value: "Value1")

        XCTAssertTrue(header1 == header2)
    }

    func testEqualityOfNotEqualHeaders() {
        let header1 = Http.Header(name: "Header1", value: "Value1")
        let header2 = Http.Header(name: "Header1", value: "Value2")

        XCTAssertFalse(header1 == header2)
    }
}
