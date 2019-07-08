//
//  ApiServiceTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 19.01.2017.
//

import XCTest
@testable import RxSwiftAPI

class ApiServiceTests: XCTestCase {

    private var apiService: ApiService!

    override func setUp() {
        super.setUp()

        apiService = ApiService(fileManager: DefaultFileManager())
    }

    override func tearDown() {
        apiService = nil
        super.tearDown()
    }

    ///Prepare JSON Data object
    private func jsonData(with dictionary: [String : Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
    }

    //Log test result
    private func log(_ response: ApiResponse?, with error: Error?) {
        let message: String
        if let response = response, let responseUrl = response.url {
            message = "Request to URL \(responseUrl) finished with status code \(response.statusCode.rawValue)."
        } else if let errorMessage = error?.localizedDescription {
            message = "Request failed: \(errorMessage)."
        } else {
            message = "Request failed."
        }
        print("--------------------")
        print(message)
        print("--------------------")
    }
}

extension ApiServiceTests {

    func testGet() {
        let url = TestData.Url.root.appendingPathComponent("get")
        let headers = TestData.Headers.example
        let responseExpectation = expectation(description: "Expect GET response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            response?.printPrettyBody()
            print("--------------------")
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.getData(from: url, with: headers, completion: completion)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "GET request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testPost() {
        let url = TestData.Url.root.appendingPathComponent("post")
        let headers = TestData.Headers.example
        let data = jsonData(with: ["title": "test", "body": "post"] as [String : Any])

        let responseExpectation = expectation(description: "Expect POST response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.post(data: data, at: url, with: headers, completion: completion)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "POST request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testPut() {
        let url = TestData.Url.root.appendingPathComponent("put")
        let headers = TestData.Headers.example
        let data = jsonData(with: ["id": 1, "title": "test", "body": "put"] as [String : Any])

        let responseExpectation = expectation(description: "Expect PUT response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.put(data: data,at: url, with: headers, completion: completion)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "PUT request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testPatch() {
        let url = TestData.Url.root.appendingPathComponent("patch")
        let headers = TestData.Headers.example
        let data = jsonData(with: ["body": "patch"] as [String : Any])

        let responseExpectation = expectation(description: "Expect PATCH response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.patch(data: data, at: url, with: headers, completion: completion)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "PATCH request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testDelete() {
        let url = TestData.Url.root.appendingPathComponent("delete")
        let responseExpectation = expectation(description: "Expect DELETE response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.delete(at: url, completion: completion)

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "DELETE request failed with error: \(responseError!.localizedDescription)")
        }
    }

    //MARK: Uploading tests
    func testPostFile() {
        let resourceUrl = TestData.Url.localFile
        let destinationUrl = TestData.Url.root.appendingPathComponent("post")
        let headers = TestData.Headers.example

        let responseExpectation = expectation(description: "Expect POST response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.postFile(from: resourceUrl, to: destinationUrl, with: headers, inBackground: false, useProgress: false, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "POST request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testPutFile() {
        let resourceUrl = TestData.Url.localFile
        let destinationUrl = TestData.Url.root.appendingPathComponent("put")
        let headers = TestData.Headers.example

        let responseExpectation = expectation(description: "Expect PUT response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.putFile(from: resourceUrl, to: destinationUrl, with: headers, inBackground: false, useProgress: false, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "PUT request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testPatchFile() {
        let resourceUrl = TestData.Url.localFile
        let destinationUrl = TestData.Url.root.appendingPathComponent("patch")
        let headers = TestData.Headers.example

        let responseExpectation = expectation(description: "Expect PATCH response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.patchFile(from: resourceUrl, to: destinationUrl, with: headers, inBackground: false, useProgress: false, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "PATCH request failed with error: \(responseError!.localizedDescription)")
        }
    }

    //MARK: Downloading tests
    func testDownloadFile() {
        let remoteResourceUrl = TestData.Url.smallFile
        let destinationUrl = TestData.Url.fileDestination
        let headers = TestData.Headers.example

        let responseExpectation = expectation(description: "Expect download response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        let request = apiService.downloadFile(from: remoteResourceUrl, to: destinationUrl, with: headers, inBackground: false, useProgress: true, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "Download request failed with error: \(responseError!.localizedDescription)")
            XCTAssertNotNil(request.uuid)
            XCTAssertNotNil(request.progress)
        }
    }

    //MARK: Methods with configuration tests
    func testUploadRequest() {
        let resourceUrl = TestData.Url.localFile
        let destinationUrl = TestData.Url.root.appendingPathComponent("put")
        let headers = TestData.Headers.example

        let responseExpectation = expectation(description: "Expect PUT response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        _ = apiService.uploadFile(from: resourceUrl, to: destinationUrl, with: .put, aditionalHeaders: headers, configuration: .ephemeral, progress: false, completion: completion)

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "Custom PUT request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testDownloadRequest() {
        let remoteResourceUrl = TestData.Url.smallFile
        let destinationUrl = TestData.Url.fileDestination
        let headers = TestData.Headers.example

        let responseExpectation = expectation(description: "Expect download response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        let request = apiService.downloadFile(from: remoteResourceUrl, to: destinationUrl, with: headers, configuration: .ephemeral, progress: false, completion: completion)
        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "Custom download request failed with error: \(responseError!.localizedDescription)")
            XCTAssertNotNil(request.uuid)
            XCTAssertNil(request.progress)
        }
    }

    //MARK: Request managing tests
    func testCancelRequest() {
        let remoteResourceUrl = TestData.Url.smallFile
        let destinationUrl = TestData.Url.fileDestination

        let responseExpectation = expectation(description: "Expect download response")
        var responseError: NSError?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error as NSError?
            responseExpectation.fulfill()
        }
        let request = apiService.downloadFile(from: remoteResourceUrl, to: destinationUrl, inBackground: false, useProgress: false, completion: completion)
        request.cancel()

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(responseError?.domain == NSURLErrorDomain && responseError?.code == -999, "Resposne should finnish with cancel error!")
        }
    }

    func testSuspendAndResume() {
        let remoteResourceUrl = TestData.Url.smallFile
        let destinationUrl = TestData.Url.fileDestination

        let responseExpectation = expectation(description: "Expect download response")
        var responseError: Error?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error
            responseExpectation.fulfill()
        }
        let request = apiService.downloadFile(from: remoteResourceUrl, to: destinationUrl, inBackground: false, useProgress: false, completion: completion)
        request.suspend()
        request.resume()

        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNil(responseError, "Download request failed with error: \(responseError!.localizedDescription)")
        }
    }

    func testCancelAllRequests() {
        let remoteResourceUrl = TestData.Url.smallFile
        let destinationUrl1 = TestData.Url.fileDestination
        let destinationUrl2 = TestData.Url.anotherFileDestination

        let responseExpectation = expectation(description: "Expect download response")
        var responseError: NSError?
        let completion = { [weak self] (response: ApiResponse?, error: Error?) in
            self?.log(response, with: error)
            responseError = error as NSError?
            responseExpectation.fulfill()
        }
        _ = apiService.downloadFile(from: remoteResourceUrl, to: destinationUrl1, inBackground: false, useProgress: false)
        _ = apiService.downloadFile(from: remoteResourceUrl, to: destinationUrl2, inBackground: false, useProgress: false, completion: completion)
        apiService.cancelAllRequests()

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(responseError?.domain == NSURLErrorDomain && responseError?.code == -999, "Resposne should finnish with cancel error!")
        }
    }
}
