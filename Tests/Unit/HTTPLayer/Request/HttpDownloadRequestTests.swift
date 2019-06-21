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

    private var exampleSuccessAction: ResponseAction {
        return ResponseAction.success {_ in}
    }

    private var exampleFailureAction: ResponseAction {
        return ResponseAction.failure {_ in}
    }

    func testFullConstructor() {
        let url = rootURL.appendingPathComponent("posts/1")
        let destination = TestData.Url.fileDestination
        let success = exampleSuccessAction
        let failure = exampleFailureAction
        let request = HttpDownloadRequest(url: url, destinationUrl: destination, onSuccess: success, onFailure: failure, useProgress: true)

        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.destinationUrl, destination)
        XCTAssertTrue(success.isEqualByType(with: request.successAction!))
        XCTAssertTrue(failure.isEqualByType(with: request.failureAction!))
        XCTAssertNotNil(request.progress)
    }

    func testHashValue() {
        let url = rootURL.appendingPathComponent("posts/1")
        let destination1 = TestData.Url.fileDestination
        let destination2 = TestData.Url.anotherFileDestination
        let success = exampleSuccessAction
        let failure = exampleFailureAction
        let request1 = HttpDownloadRequest(url: url, destinationUrl: destination1, onSuccess: success, onFailure: failure, useProgress: true)
        let request2 = HttpDownloadRequest(url: url, destinationUrl: destination2, onSuccess: success, onFailure: failure, useProgress: true)

        XCTAssertTrue(request1.hashValue == request1.hashValue)
        XCTAssertFalse(request1.hashValue == request2.hashValue)
    }
}
