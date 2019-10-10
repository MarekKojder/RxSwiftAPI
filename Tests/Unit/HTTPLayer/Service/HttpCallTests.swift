//
//  HttpCallTests.swift
//  UnitTests iOS
//
//  Created by Marek Kojder on 08.03.2018.
//

import XCTest
@testable import RxSwiftAPI

class HttpCallTests: XCTestCase {

    var progressBlock: SessionService.ProgressHandler {
        return { (_) in }
    }

    var completionBlock: SessionService.CompletionHandler {
        return { (_, _) in }
    }

//    func testProgressBlock() {
//        let blockExpectation = expectation(description: "Expect progress block")
//        var processed = Int64(0)
//        var expectedToProcess = Int64(0)
//        let progress: SessionService.ProgressHandler = { progress in
//            processed = totalBytesProcessed
//            expectedToProcess = totalBytesExpectedToProcess
//            blockExpectation.fulfill()
//        }
////        let call = HttpCall(progress: progress, completion: completionBlock)
//        call.performCompletion(response: HttpResponse(body: Data()), error: nil)
//        call.performProgress(totalBytesProcessed: 100, totalBytesExpectedToProcess: 200)
//
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
//            XCTAssertEqual(processed, 100)
//            XCTAssertEqual(expectedToProcess, 200)
//        }
//    }

//    func testSuccessBlock() {
//        let blockExpectation = expectation(description: "Expect success block")
//        let testResponse = HttpResponse(body: Data())
//        var receivedResponse: HttpResponse?
//        let success: SessionService.CompletionHandler = { (response, _) in
//            receivedResponse = response
//            blockExpectation.fulfill()
//        }
//
//        let call = HttpCall(progress: progressBlock, completion: success)
//        call.performProgress(totalBytesProcessed: 0, totalBytesExpectedToProcess: 0)
//        call.performCompletion(response: testResponse, error: nil)
//
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
//            XCTAssertNotNil(receivedResponse)
//            XCTAssertEqual(receivedResponse?.url, testResponse.url)
//            XCTAssertEqual(receivedResponse?.expectedContentLength, testResponse.expectedContentLength)
//            XCTAssertEqual(receivedResponse?.body, testResponse.body)
//        }
//    }

//    func testFailureBlock() {
//        let blockExpectation = expectation(description: "Expect progress block")
//        let testError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
//        var receivedError: NSError?
//        let failure: SessionService.CompletionHandler = { (_, error) in
//            receivedError = error as NSError?
//            blockExpectation.fulfill()
//        }
//
//        let call = HttpCall(progress: progressBlock, completion: failure)
//        call.performProgress(totalBytesProcessed: 0, totalBytesExpectedToProcess: 0)
//        call.performCompletion(response: nil, error: testError)
//
//        waitForExpectations(timeout: 10) { error in
//            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
//            XCTAssertEqual(receivedError, testError)
//        }
//    }
//
//    func testUpdateWithData() {
//        let call = HttpCall(progress: progressBlock, completion: completionBlock)
//        let data = Data(capacity: 10)
//
//        call.update(with: data)
//
//        XCTAssertNotNil(call.response)
//        XCTAssertEqual(call.response?.body, data)
//    }
//
//    func testUpdateWithUrl() {
//        let call = HttpCall(progress: progressBlock, completion: completionBlock)
//        let url1 = URL(string: "http://cocoapods.org/")!
//        let url2 = URL(string: "http://cocoapods.org/pods/RxSwiftAPI")!
//        call.update(with: URLResponse(url: url1, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))
//        call.update(with: url2)
//
//        XCTAssertNotNil(call.response)
//        XCTAssertEqual(call.response?.resourceUrl, url2)
//    }
}
