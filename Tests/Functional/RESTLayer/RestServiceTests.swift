//
//  RestServiceTests.swift
//  RxSwiftAPI
//
//  Created by Marek Kojder on 07.02.2017.
//

import XCTest
@testable import RxSwiftAPI

struct ExampleData: Codable {
    let url: URL
}

struct ExampleParameters: Codable {
    let parameter: String
    let count: Int
}

struct EmptyParameters: Codable {}

struct ExampleFailData: Codable {
    let notExistingProperty: Int
}

enum ExamplePath: String, ResourcePath {
    case get
    case post
    case patch
    case put
    case delete
    case notFound

    case none = ""
    case fileToDownload = "commons/thumb/5/53/Wikipedia-logo-en-big.png/489px-Wikipedia-logo-en-big.png"
}

class RestServiceTests: XCTestCase {

    private var restService: Rest.Service!

    private var downloadRestService: Rest.Service!

    private var exampleData: ExampleData {
        return ExampleData(url: TestData.Url.root)
    }

    override func setUp() {
        super.setUp()

        restService = Rest.Service(baseUrl: TestData.Path.root,
                                   headerFields: TestData.Headers.example)

        downloadRestService = Rest.Service(baseUrl: TestData.Path.downloadRoot,
                                           apiPath: "wikipedia/",
                                           headerFields: nil)
    }

    override func tearDown() {
        restService = nil
        downloadRestService = nil
        super.tearDown()
    }

    private func log(_ details: Rest.Response.Details, for path: ResourcePath, and resource: Codable? = nil) {
        var message = "Request for resource \(path.rawValue)"
        if details.statusCode.isSuccess {
            message.append(" succeeded.")
        } else {
            message.append(" failed with error: \(details.statusCode.description).")
        }
        print("--------------------")
        print(message)
        print("--------------------")
    }
}

extension RestServiceTests {

    //MARK: Simple requests tests
    func testGet() {
        let type = ExampleData.self
        let path = ExamplePath.get
        let parameters = ExampleParameters(parameter: "parameter", count: 1)
        let responseExpectation = expectation(description: "Expect GET response")
        var responseFailed = true
        let completion: Rest.Response.CompletionHandler<ExampleData> = { [weak self] (data, details) in
            self?.log(details, for: path)
            details.printPrettyBody()
            print("--------------------")
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.get(type: type, from: path, parameters: parameters, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "GET request failed with error")
        }
    }

    func testParsingFailureGet() {
        let type = ExampleFailData.self
        let path = ExamplePath.get
        let parameters = EmptyParameters()
        let responseExpectation = expectation(description: "Expect GET response")
        var responseError: Error? = nil
        let completion: Rest.Response.CompletionHandler<ExampleFailData> = { [weak self] (data, details) in
            self?.log(details, for: path)
            responseError = details.error
            responseExpectation.fulfill()
        }
        do {
            try restService.get(type: type, from: path, parameters: parameters, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertNotNil(responseError, "GET request should fail")
        }
    }

    func testNotFoundFailureGet() {
        let type = ExampleData.self
        let path = ExamplePath.notFound
        let responseExpectation = expectation(description: "Expect GET response")
        var responseFailed = true
        let completion: Rest.Response.CompletionHandler<ExampleData> = { [weak self] (data, details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.get(type: type, from: path, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(responseFailed, "GET request should fail")
        }
    }

    func testUrlFailureGet() {
        let service = Rest.Service(baseUrl: "")
        let type = ExampleData.self
        let path = ExamplePath.none
        do {
            try service.get(type: type, from: path)
            XCTFail("Request should throw an exception")
        } catch {
            XCTAssertEqual(error.localizedDescription, Rest.Error.url.localizedDescription)
        }
    }

    func testSimplePost() {
        let value: ExampleData? = nil
        let path = ExamplePath.post
        let responseExpectation = expectation(description: "Expect POST response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.post(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "POST request failed with error")
        }
    }

    func testPost() {
        let value = exampleData
        let path = ExamplePath.post
        let responseExpectation = expectation(description: "Expect POST response")
        var responseFailed = true
        let completion = { [weak self] (data: ExampleData?, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.post(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "POST request failed with error")
        }
    }

    func testSimplePut() {
        let value: ExampleData? = nil
        let path = ExamplePath.put
        let responseExpectation = expectation(description: "Expect PUT response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.put(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "PUT request failed with error")
        }
    }

    func testPut() {
        let value = exampleData
        let path = ExamplePath.put
        let responseExpectation = expectation(description: "Expect PUT response")
        var responseFailed = true
        let completion = { [weak self] (data: ExampleData?, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.put(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "PUT request failed with error")
        }
    }

    func testSimplePatch() {
        let value: ExampleData? = nil
        let path = ExamplePath.patch
        let responseExpectation = expectation(description: "Expect PATCH response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.patch(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "PATCH request failed with error")
        }
    }

    func testPatch() {
        let value = exampleData
        let path = ExamplePath.patch
        let responseExpectation = expectation(description: "Expect PATCH response")
        var responseFailed = true
        let completion = { [weak self] (data: ExampleData?, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.patch(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "PATCH request failed with error")
        }
    }

    func testSimpleDelete() {
        let value: ExampleData? = nil
        let path = ExamplePath.delete
        let responseExpectation = expectation(description: "Expect DELETE response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.delete(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "DELETE request failed with error")
        }
    }

    func testDelete() {
        let value = exampleData
        let path = ExamplePath.delete
        let responseExpectation = expectation(description: "Expect DELETE response")
        var responseFailed = true
        let completion = { [weak self] (data: ExampleData?, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try restService.delete(value, at: path, aditionalHeaders: TestData.Headers.auth, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "DELETE request failed with error")
        }
    }

    //MARK: File requests tests
    func testGetFile() {
        let path = ExamplePath.fileToDownload
        let location = TestData.Url.fileDestination
        let responseExpectation = expectation(description: "Expect GET response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = downloadRestService.getFile(at: path, saveAt: location, configuration: .foreground, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "GET request failed with error")
        }
    }

    func testGetFileWithParameters() {
        let path = ExamplePath.fileToDownload
        let location = TestData.Url.fileDestination
        let parameters = EmptyParameters()
        let responseExpectation = expectation(description: "Expect GET response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = downloadRestService.getFile(at: path, parameters: parameters, saveAt: location, configuration: .foreground, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "GET request failed with error")
        }
    }

    func testWrongPathGetFile() {
        let path = ExamplePath.fileToDownload
        let location = TestData.Url.fileDestination
        let responseExpectation = expectation(description: "Expect GET response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = restService.getFile(at: path, saveAt: location, configuration: .foreground, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 60) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(responseFailed, "GET request should fail")
        }
    }

    func testPostFile() {
        let path = ExamplePath.post
        let location = TestData.Url.localFile
        let responseExpectation = expectation(description: "Expect POST response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = restService.postFile(from: location, at: path, configuration: .foreground, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "POST request failed with error")
        }
    }

    func testPutFile() {
        let path = ExamplePath.put
        let location = TestData.Url.localFile
        let responseExpectation = expectation(description: "Expect PUT response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = restService.putFile(from: location, at: path, configuration: .foreground, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "PUT request failed with error")
        }
    }

    func testPatchFile() {
        let path = ExamplePath.patch
        let location = TestData.Url.localFile
        let responseExpectation = expectation(description: "Expect PATCH response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = restService.patchFile(from: location, at: path, configuration: .foreground, completion: completion)
        } catch {
            XCTFail(error.localizedDescription)
        }
        waitForExpectations(timeout: 300) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertFalse(responseFailed, "PATCH request failed with error")
        }
    }

    func testCancelAllRequests() {
        let path1 = ExamplePath.put
        let path2 = ExamplePath.patch
        let path3 = ExamplePath.get
        let location = TestData.Url.localFile
        let responseExpectation = expectation(description: "Expect error response")
        var responseFailed = true
        let completion = { [weak self] (success: Bool, details: Rest.Response.Details) in
            self?.log(details, for: path2)
            responseFailed = !details.statusCode.isSuccess
            responseExpectation.fulfill()
        }
        do {
            try _ = restService.putFile(from: location, at: path1, configuration: .foreground)
            try _ = restService.patchFile(from: location, at: path2, configuration: .foreground, completion: completion)
            try restService.get(type: ExampleData.self, from: path3)
            restService.cancelAllRequests()
        } catch {
            XCTFail(error.localizedDescription)
        }

        waitForExpectations(timeout: 30) { error in
            XCTAssertNil(error, "Test failed with error: \(error!.localizedDescription)")
            XCTAssertTrue(responseFailed, "Request should fail")
        }
    }
}
