//
//  HttpRequestTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 04.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class HttpDataRequestTests: XCTestCase {

    private var rootURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }

    private var exampleBody: Data {
        return "Example string.".data(using: .utf8)!
    }

    func testFullConstructor() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let body = exampleBody
        let request = HttpDataRequest(url: url, method: method, body: body, useProgress: true)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
        XCTAssertEqual(request.body, body)
        XCTAssertNotNil(request.progress)
    }

    func testUrlRequest() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let body = exampleBody
        let request = HttpDataRequest(url: url, method: method, body: body, useProgress: true)
        let urlRequest = request.urlRequest

        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(urlRequest.httpBody, body)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let body = exampleBody
        let request1 = HttpDataRequest(url: url, method: method, body: body, useProgress: true)
        let request2 = HttpDataRequest(url: url, method: method, body: nil, useProgress: true)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
