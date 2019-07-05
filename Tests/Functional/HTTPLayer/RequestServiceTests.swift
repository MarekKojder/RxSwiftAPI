//
//  RequestServiceTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 04.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class RequestServiceTests: XCTestCase {

    private var requestService: RequestService!

    override func setUp() {
        super.setUp()

        requestService = RequestService(fileManager: DefaultFileManager())
    }

    override func tearDown() {
        requestService = nil
        super.tearDown()
    }
}

extension RequestServiceTests {

    //MARK: - DataRequest tests
    func testHttpGetDataRequest() {
        let url = TestData.Url.root.appendingPathComponent("get")

        performTestDataRequest(url: url, method: .get)
    }

    func testHttpPostDataRequest() {
        let url = TestData.Url.root.appendingPathComponent("post")
        let body = jsonData(with: ["title": "test", "body": "post", "userId": 1] as [String : Any])

        performTestDataRequest(url: url, method: .post, body: body)
    }

    func testHttpPutDataRequest() {
        let url = TestData.Url.root.appendingPathComponent("put")
        let body = jsonData(with: ["id": 1, "title": "test", "body": "put", "userId": 1] as [String : Any])

        performTestDataRequest(url: url, method: .put, body: body)
    }

    func testHttpPatchDataRequest() {
        let url = TestData.Url.root.appendingPathComponent("patch")
        let body = jsonData(with: ["body": "patch"] as [String : Any])

        performTestDataRequest(url: url, method: .patch, body: body)
    }

    func testHttpDeleteDataRequest() {
        let url = TestData.Url.root.appendingPathComponent("delete")

        performTestDataRequest(url: url, method: .delete)
    }

    //MARK: UploadRequest tests
    func testHttpPostUploadRequest() {
        let url = TestData.Url.root.appendingPathComponent("post")
        let resourceUrl = TestData.Url.localFile

        performTestUploadRequest(url: url, method: .post, resourceUrl: resourceUrl)
    }

    func testHttpPutUploadRequest() {
        let url = TestData.Url.root.appendingPathComponent("put")
        let resourceUrl = TestData.Url.localFile

        performTestUploadRequest(url: url, method: .put, resourceUrl: resourceUrl)
    }

    func testHttpPatchUploadRequest() {
        let url = TestData.Url.root.appendingPathComponent("patch")
        let resourceUrl = TestData.Url.localFile

        performTestUploadRequest(url: url, method: .patch, resourceUrl: resourceUrl)
    }

    //MARK: DownloadRequest tests
    func testHttpDownloadRequest() {
        let fileUrl = TestData.Url.smallFile
        let destinationUrl = TestData.Url.fileDestination
        let responseExpectation = expectation(description: "Expect response from \(fileUrl)")
        var successPerformed = false
        var failurePerformed = false
        var responseError: NSError?
        let completion: HttpRequestCompletionHandler = { response, error in
            let message: String
            if let error = error {
                failurePerformed = true
                responseError = error as NSError?
                message = "failed with error: \(error.localizedDescription)."
            } else if let response = response {
                if let code = response.statusCode {
                    message = "finished with status code \(code)."
                } else {
                    message = "finished."
                }
                successPerformed = true
            } else {
                message = "finished without success or error."
            }
            print("--------------------")
            print("HttpDownloadRequest from URL \(fileUrl) \(message)")
            print("--------------------")
            responseExpectation.fulfill()
        }

        let request = HttpDownloadRequest(url: fileUrl, destinationUrl: destinationUrl, useProgress: false)
        requestService.sendHTTPRequest(request, with: .foreground, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Download request test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(failurePerformed, "Download request finished with failure: \(responseError!.localizedDescription)")
            XCTAssertTrue(successPerformed)
        }
    }

    //MARK: Request managing tests
    func testHttpRequestCancel() {
        let fileUrl = TestData.Url.smallFile
        let destinationUrl = TestData.Url.fileDestination
        let responseExpectation = expectation(description: "Expect response from \(fileUrl)")
        var successPerformed = false
        var failurePerformed = false
        var responseError: NSError?
        let completion: HttpRequestCompletionHandler = { response, error in
            let message: String
            if let error = error {
                failurePerformed = true
                responseError = error as NSError?
                message = "failed with error: \(error.localizedDescription)."
            } else if let response = response {
                if let code = response.statusCode {
                    message = "finished with status code \(code)."
                } else {
                    message = "finished."
                }
                successPerformed = true
            } else {
                message = "finished without success or error."
            }
            print("--------------------")
            print("HttpDownloadRequest from URL \(fileUrl) \(message)")
            print("--------------------")
            responseExpectation.fulfill()
        }

        let request = HttpDownloadRequest(url: fileUrl, destinationUrl: destinationUrl, useProgress: false)
        requestService.sendHTTPRequest(request, with: .foreground, completion: completion)
        requestService.cancel(request)

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "Download request test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(failurePerformed)
            XCTAssertTrue(responseError?.domain == NSURLErrorDomain && responseError?.code == -999, "Resposne should finnish with cancel error!")
            XCTAssertFalse(successPerformed)
        }
    }

    func testHttpRequestCancelAll() {
        let fileUrl1 = TestData.Url.bigFile
        let fileUrl2 = TestData.Url.bigFile
        let destinationUrl = TestData.Url.fileDestination
        let responseExpectation = expectation(description: "Expect file")
        var successPerformed = false
        var failurePerformed = false
        var responseError: NSError?
        let completion: HttpRequestCompletionHandler = { response, error in
            let message: String
            if let error = error {
                failurePerformed = true
                responseError = error as NSError?
                message = "failed with error: \(error.localizedDescription)."
            } else if let response = response {
                if let code = response.statusCode {
                    message = "finished with status code \(code)."
                } else {
                    message = "finished."
                }
                successPerformed = true
            } else {
                message = "finished without success or error."
            }
            print("--------------------")
            print("HttpDownloadRequest from URL \(fileUrl2) \(message)")
            print("--------------------")
            responseExpectation.fulfill()
        }
        
        let request1 = HttpDownloadRequest(url: fileUrl1, destinationUrl: destinationUrl, useProgress: false)
        let request2 = HttpDownloadRequest(url: fileUrl2, destinationUrl: destinationUrl, useProgress: false)

        requestService.sendHTTPRequest(request1, with: .foreground, completion: {_, _ in })
        requestService.sendHTTPRequest(request2, with: .foreground, completion: completion)
        requestService.cancelAllRequests()

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "Download request test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(failurePerformed)
            XCTAssertTrue(responseError?.domain == NSURLErrorDomain && responseError?.code == -999, "Resposne should finnish with cancel error!")
            XCTAssertFalse(successPerformed)
        }
    }

    func testSuspendAndResume() {
        let url = TestData.Url.root.appendingPathComponent("get")
        let method = HttpMethod.get
        let responseExpectation = expectation(description: "Expect response from \(url)")
        var successPerformed = false
        var failurePerformed = false
        var responseError: Error?
        let completion: HttpRequestCompletionHandler = { response, error in
            let message: String
            if let error = error {
                failurePerformed = true
                responseError = error
                message = "failed with error: \(error.localizedDescription)."
            } else if let response = response {
                if let code = response.statusCode {
                    message = "finished with status code \(code)."
                } else {
                    message = "finished."
                }
                successPerformed = true
            } else {
                message = "finished without success or error."
            }
            print("--------------------")
            print("\(method.rawValue) request to URL \(url) \(message)")
            print("--------------------")
            responseExpectation.fulfill()
        }

        let request = HttpDataRequest(url: url, method: method)
        requestService.sendHTTPRequest(request, completion: completion)
        requestService.suspend(request)
        requestService.resume(request)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "\(method.rawValue) request test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(failurePerformed, "\(method.rawValue) request finished with failure: \(responseError!.localizedDescription)")
            XCTAssertTrue(successPerformed)
        }
    }
}


extension RequestServiceTests {

    ///Prepare JSON Data object
    fileprivate func jsonData(with dictionary: [String : Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }

    ///Perform test of data request with given parameters
    fileprivate func performTestDataRequest(url: URL, method: HttpMethod, body: Data? = nil, file: StaticString = #file, line: UInt = #line) {
        let responseExpectation = expectation(description: "Expect response from \(url)")
        var successPerformed = false
        var failurePerformed = false
        var responseError: Error?
        let completion: HttpRequestCompletionHandler = { response, error in
            let message: String
            if let error = error {
                failurePerformed = true
                responseError = error
                message = "failed with error: \(error.localizedDescription)."
            } else if let response = response {
                if let code = response.statusCode {
                    message = "finished with status code \(code)."
                } else {
                    message = "finished."
                }
                successPerformed = true
            } else {
                message = "finished without success or error."
            }
            print("--------------------")
            print("\(method.rawValue) request to URL \(url) \(message)")
            print("--------------------")
            responseExpectation.fulfill()
        }

        let request = HttpDataRequest(url: url, method: method, body: body)
        requestService.sendHTTPRequest(request, completion: completion)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "\(method.rawValue) request test failed with error: \(error!.localizedDescription)", file: file, line: line)
            XCTAssertFalse(failurePerformed, "\(method.rawValue) request finished with failure: \(responseError!.localizedDescription)", file: file, line: line)
            XCTAssertTrue(successPerformed, file: file, line: line)
        }
    }

    ///Perform test of upload request with given parameters
    fileprivate func performTestUploadRequest(url: URL, method: HttpMethod, resourceUrl: URL, file: StaticString = #file, line: UInt = #line) {
        let responseExpectation = expectation(description: "Expect response from \(url)")
        var successPerformed = false
        var failurePerformed = false
        var responseError: Error?
        let completion: HttpRequestCompletionHandler = { response, error in
            let message: String
            if let error = error {
                failurePerformed = true
                responseError = error
                message = "failed with error: \(error.localizedDescription)."
            } else if let response = response {
                if let code = response.statusCode {
                    message = "finished with status code \(code)."
                } else {
                    message = "finished."
                }
                successPerformed = true
            } else {
                message = "finished without success or error."
            }
            print("--------------------")
            print("\(method.rawValue) request to URL \(url) \(message)")
            print("--------------------")
            responseExpectation.fulfill()
        }

        let request = HttpUploadRequest(url: url, method: method, resourceUrl: resourceUrl, useProgress: false)
        requestService.sendHTTPRequest(request, with: .foreground, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "\(method.rawValue) request test failed with error: \(error!.localizedDescription)", file: file, line: line)
            XCTAssertFalse(failurePerformed, "\(method.rawValue) request finished with failure: \(responseError!.localizedDescription)", file: file, line: line)
            XCTAssertTrue(successPerformed, file: file, line: line)
        }
    }
}
