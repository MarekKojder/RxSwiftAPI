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
        let method = HttpMethod.get
        let request = HttpRequest(url: url, method: method)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
        XCTAssertNil(request.progress)
    }

    func testFullConstructorWithoutProgress() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let request = HttpRequest(url: url, method: method, useProgress: false)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
        XCTAssertNil(request.progress)
    }

    func testFullConstructorWithProgress() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let request = HttpRequest(url: url, method: method, useProgress: true)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
        XCTAssertNotNil(request.progress)
    }

    func testEqualityOfEqualRequests() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let request1 = HttpRequest(url: url, method: method, useProgress: true)
        let request2 = request1

        XCTAssertTrue(request1 == request2)
    }

    func testEqualityOfNotEqualRequests() {
        let url = rootURL.appendingPathComponent("posts/1")
        let request1 = HttpRequest(url: url, method: .get, useProgress: true)
        let request2 = HttpRequest(url: url, method: .post, useProgress: true)
        let request3 = HttpRequest(url: url, method: .post, useProgress: true)

        XCTAssertFalse(request1 == request2)
        XCTAssertFalse(request1 == request3)
        XCTAssertFalse(request2 == request3)
    }

    func testUrlRequest() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let request = HttpRequest(url: url, method: method, useProgress: true)
        let urlRequest = request.urlRequest

        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, method.rawValue)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let request1 = HttpRequest(url: url, method: .post, useProgress: true)
        let request2 = HttpRequest(url: url, method: .get, useProgress: true)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
