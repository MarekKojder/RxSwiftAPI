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

    private var exampleCompletionAction: Http.Service.CompletionHandler {
        return {_, _ in}
    }

    func testFullConstructor() {
        let url = rootURL.appendingPathComponent("posts/1")
        let destination = TestData.Url.fileDestination
        let request = Http.DownloadRequest(url: url, destinationUrl: destination)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.destinationUrl, destination)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let destination1 = TestData.Url.fileDestination
        let destination2 = TestData.Url.anotherFileDestination
        let request1 = Http.DownloadRequest(url: url, destinationUrl: destination1)
        let request2 = Http.DownloadRequest(url: url, destinationUrl: destination2)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
