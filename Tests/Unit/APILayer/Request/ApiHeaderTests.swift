//
//  ApiHeaderTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 30.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class ApiHeaderTests: XCTestCase {
    
    func testHashValue() {
        let header1 = Api.Header(name: "Header1", value: "Value1")
        let header2 = Api.Header(name: "Header2", value: "Value2")

        XCTAssertTrue(header1.hashValue == header1.hashValue)
        XCTAssertFalse(header1.hashValue == header2.hashValue)
    }

    func testEqualityOfEqualHeaders() {
        let header1 = Api.Header(name: "Header1", value: "Value1")
        let header2 = Api.Header(name: "Header1", value: "Value1")

        XCTAssertTrue(header1 == header2)
    }

    func testEqualityOfNotEqualHeaders() {
        let header1 = Api.Header(name: "Header1", value: "Value1")
        let header2 = Api.Header(name: "Header1", value: "Value2")

        XCTAssertFalse(header1 == header2)
    }

    func testHttpHeader() {
        let header = Api.Header(name: "Header1", value: "Value1")
        let httpHeader = header.httpHeader

        XCTAssertTrue(header.name == httpHeader.name)
        XCTAssertTrue(header.value == httpHeader.value)
    }

    func testBasicAuthHeader() {
        let login = "admin"
        let password = "admin1"
        let header = Api.Header.Authorization.basic(login: login, password: password)
        let credentials = "\(login):\(password)".data(using: .utf8)?.base64EncodedString(options: .init(rawValue: 0))

        XCTAssertEqual(header?.name, "Authorization")
        XCTAssertEqual(header?.value, "Basic \(credentials!)")
    }

    func testCustomAuthHeader() {
        let value = "32f45b55nynh6u6n7j6j786b47ub67jb67jb5"
        let header = Api.Header.Authorization.with(value)

        XCTAssertEqual(header.name, "Authorization")
        XCTAssertEqual(header.value, value)
    }

    func testPlainTextHeader() {
        let header = Api.Header.ContentType.plainText

        XCTAssertEqual(header.name, "Content-Type")
        XCTAssertEqual(header.value, "text/plain")
    }

    func testJsonHeader() {
        let header = Api.Header.ContentType.json

        XCTAssertEqual(header.name, "Content-Type")
        XCTAssertEqual(header.value, "application/json")
    }

    func testUrlEncodedHeader() {
        let header = Api.Header.ContentType.urlEncoded

        XCTAssertEqual(header.name, "Content-Type")
        XCTAssertEqual(header.value, "application/x-www-form-urlencoded")
    }

    func testMultipartHeader() {
        let boundary = "v867fvi82374nr347by57t0234tb2"
        let header = Api.Header.ContentType.multipart(with: boundary)

        XCTAssertEqual(header.name, "Content-Type")
        XCTAssertEqual(header.value, "multipart/form-data; boundary=\(boundary)")
    }
}
