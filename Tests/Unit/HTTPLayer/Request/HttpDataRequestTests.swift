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
        let method = Http.Method.get
        let body = exampleBody
        let request = Http.DataRequest(url: url, method: method, body: body)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
        XCTAssertEqual(request.body, body)
    }

    func testUrlRequest() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let body = exampleBody
        let request = Http.DataRequest(url: url, method: method, body: body)
        let urlRequest = request.urlRequest

        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(urlRequest.httpBody, body)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let body = exampleBody
        let request1 = Http.DataRequest(url: url, method: method, body: body)
        let request2 = Http.DataRequest(url: url, method: method, body: nil)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
