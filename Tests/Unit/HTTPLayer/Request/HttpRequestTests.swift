//
//  HttpRequestTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 04.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class HttpRequestTests: XCTestCase {

    private var rootURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }

    func testBasicConstructor() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let request = Http.Request(url: url, method: method)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
    }

    func testFullConstructorWithoutProgress() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let request = Http.Request(url: url, method: method)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
    }

    func testFullConstructorWithProgress() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let request = Http.Request(url: url, method: method)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
    }

    func testEqualityOfEqualRequests() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let request1 = Http.Request(url: url, method: method)
        let request2 = request1

        XCTAssertTrue(request1 == request2)
    }

    func testEqualityOfNotEqualRequests() {
        let url = rootURL.appendingPathComponent("posts/1")
        let request1 = Http.Request(url: url, method: .get)
        let request2 = Http.Request(url: url, method: .post)
        let request3 = Http.Request(url: url, method: .post)

        XCTAssertFalse(request1 == request2)
        XCTAssertFalse(request1 == request3)
        XCTAssertFalse(request2 == request3)
    }

    func testUrlRequest() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = Http.Method.get
        let request = Http.Request(url: url, method: method)
        let urlRequest = request.urlRequest

        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, method.rawValue)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let request1 = Http.Request(url: url, method: .post)
        let request2 = Http.Request(url: url, method: .get)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
