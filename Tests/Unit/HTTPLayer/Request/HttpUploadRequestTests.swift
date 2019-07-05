//
//  HttpRequestTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 04.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class HttpUploadRequestTests: XCTestCase {

    private var rootURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }

    func testFullConstructor() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.get
        let resource = TestData.Url.fileDestination
        let request = HttpUploadRequest(url: url, method: method, resourceUrl: resource, useProgress: true)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, method)
        XCTAssertEqual(request.resourceUrl, resource)
        XCTAssertNotNil(request.progress)
    }
    
    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let method = HttpMethod.post
        let resource1 = TestData.Url.fileDestination
        let resource2 = TestData.Url.anotherFileDestination
        let request1 = HttpUploadRequest(url: url, method: method, resourceUrl: resource1, useProgress: true)
        let request2 = HttpUploadRequest(url: url, method: method, resourceUrl: resource2, useProgress: true)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
