//
//  HttpRequestTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 04.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class HttpDownloadRequestTests: XCTestCase {

    private var rootURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }

    private var exampleCompletionAction: HttpRequestCompletionHandler {
        return {_, _ in}
    }

    func testFullConstructor() {
        let url = rootURL.appendingPathComponent("posts/1")
        let destination = TestData.Url.fileDestination
        let request = HttpDownloadRequest(url: url, destinationUrl: destination, useProgress: true)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.destinationUrl, destination)
        XCTAssertNotNil(request.progress)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let destination1 = TestData.Url.fileDestination
        let destination2 = TestData.Url.anotherFileDestination
        let request1 = HttpDownloadRequest(url: url, destinationUrl: destination1, useProgress: true)
        let request2 = HttpDownloadRequest(url: url, destinationUrl: destination2, useProgress: true)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
